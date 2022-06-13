package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"regexp"
	"strconv"
)

func main() {
	Path := os.Args[1]
	dirContents, err := readDirFiles(Path)
	if err != nil {
		print(err)
		os.Exit(1)
	}

	for _, file := range dirContents {
		filePath := Path + "\\" + file.Name()
		inFile, err := os.Open(filePath)
		if err != nil {
			print(err)
			os.Exit(1)
		}
		defer inFile.Close()

		scanner := bufio.NewScanner(inFile)

		lineNum := 1
		fmt.Println("Current File in Scan: " + filePath)
		for scanner.Scan() {
			if checkForCreds(scanner.Text()) {
				fmt.Println("Found JWT in File: " + filePath)
				fmt.Println("Line Num: " + strconv.Itoa(lineNum))
				fmt.Println("JWT: " + scanner.Text())
			}
			lineNum++
		}
	}

}

func readDirFiles(dir string) ([]os.FileInfo, error) {
	filesInDir, err := ioutil.ReadDir(dir)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(filesInDir)

	return filesInDir, err
}

func checkForCreds(inStr string) bool {
	//TODO: Check For Other cred types
	matched := checkForJWT(inStr)

	return matched
}

func checkForJWT(inStr string) bool {
	//Ref: https://stackoverflow.com/questions/61802832/regex-to-match-jwt
	JWT_RegEx := regexp.MustCompile("eyJ[A-Za-z0-9-_]*\\.[A-Za-z0-9-_]*\\.[A-Za-z0-9-_]*")
	matched := JWT_RegEx.MatchString(inStr)
	if matched {
		fmt.Println("JWT Found")
	}
	return matched
}
