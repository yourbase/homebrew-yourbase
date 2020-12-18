// Copyright 2020 YourBase Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//		 https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
)

func main() {
	tag := flag.String("tag", "", "yb tag")
	commit := flag.String("commit", "", "yb commit for tag")
	flag.Parse()
	if flag.NArg() != 0 || *tag == "" || *commit == "" {
		flag.Usage()
		os.Exit(64)
	}

	archiveSHA256, err := findArchiveChecksum(*tag)
	if err != nil {
		fmt.Fprintln(os.Stderr, "editformula:", err)
		os.Exit(1)
	}
	err = modifyFile(filepath.Join("Formula", "yb-preview.rb"), func(original []byte) ([]byte, error) {
		return rewriteFormula(original, *tag, *commit, archiveSHA256)
	})
	if err != nil {
		fmt.Fprintln(os.Stderr, "editformula:", err)
		os.Exit(1)
	}
	if strings.Contains(*tag, "-") {
		return
	}
	err = modifyFile(filepath.Join("Formula", "yb.rb"), func(original []byte) ([]byte, error) {
		return rewriteFormula(original, *tag, *commit, archiveSHA256)
	})
	if err != nil {
		fmt.Fprintln(os.Stderr, "editformula:", err)
		os.Exit(1)
	}
}

func rewriteFormula(original []byte, tag, commit string, archiveSHA256 [sha256.Size]byte) ([]byte, error) {
	methodCalls := map[string]string{
		"url":    archiveURL(tag).String(),
		"sha256": hex.EncodeToString(archiveSHA256[:]),
	}
	installEnv := map[string]string{
		"GITHUB_SHA": commit,
	}

	buf := new(bytes.Buffer)
linesLoop:
	for lineno, line := range bytes.Split(original, []byte("\n")) {
		if lineno > 0 {
			buf.WriteByte('\n')
		}
		indentEnd := bytes.IndexFunc(line, func(r rune) bool { return r != ' ' && r != '\t' })
		if indentEnd == -1 {
			buf.Write(line)
			continue
		}
		for name, value := range methodCalls {
			if bytes.HasPrefix(line[indentEnd:], []byte(name+" ")) {
				fmt.Fprintf(buf, "%s%s %q", line[:indentEnd], name, value)
				continue linesLoop
			}
		}
		for name, value := range installEnv {
			prefix := []byte(`ENV["` + name + `"] =`)
			if bytes.HasPrefix(line[indentEnd:], prefix) {
				fmt.Fprintf(buf, "%sENV[%q] = %q", line[:indentEnd], name, value)
				continue linesLoop
			}
		}

		// Not a line we understand. Write it verbatim.
		buf.Write(line)
	}
	return buf.Bytes(), nil
}

func archiveURL(tag string) *url.URL {
	return &url.URL{
		Scheme: "https",
		Host:   "github.com",
		Path:   "/yourbase/yb/archive/" + tag + ".tar.gz",
	}
}

func findArchiveChecksum(tag string) ([sha256.Size]byte, error) {
	resp, err := http.DefaultClient.Do(&http.Request{
		Method: http.MethodGet,
		URL:    archiveURL(tag),
	})
	if err != nil {
		return [sha256.Size]byte{}, fmt.Errorf("find %s archive checksum: %w", tag, err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return [sha256.Size]byte{}, fmt.Errorf("find %s archive checksum: http %s", tag, resp.Status)
	}
	h := sha256.New()
	if _, err := io.Copy(h, resp.Body); err != nil {
		return [sha256.Size]byte{}, fmt.Errorf("find %s archive checksum: read response: %w", tag, err)
	}
	var sum [sha256.Size]byte
	h.Sum(sum[:0])
	return sum, nil
}

func modifyFile(path string, transform func([]byte) ([]byte, error)) (err error) {
	f, err := os.OpenFile(path, os.O_RDWR, 0)
	if err != nil {
		return fmt.Errorf("modify file %s: %w", path, err)
	}
	defer func() {
		if closeErr := f.Close(); err == nil && closeErr != nil {
			err = fmt.Errorf("modify file %s: %w", path, closeErr)
		}
	}()
	original, err := ioutil.ReadAll(f)
	if err != nil {
		return fmt.Errorf("modify file %s: %w", path, err)
	}
	new, err := transform(original)
	if err != nil {
		return fmt.Errorf("modify file %s: %w", path, err)
	}
	if _, err := f.Seek(0, io.SeekStart); err != nil {
		return fmt.Errorf("modify file %s: %w", path, err)
	}
	if err := f.Truncate(0); err != nil {
		return fmt.Errorf("modify file %s: %w", path, err)
	}
	if _, err := f.Write(new); err != nil {
		return fmt.Errorf("modify file %s: %w", path, err)
	}
	return nil
}
