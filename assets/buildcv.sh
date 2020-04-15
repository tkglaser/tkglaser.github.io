#/bin/bash

pandoc --reference-docx=word-template.docx -o output.docx -f markdown -t docx ThomasGlaserCV.md