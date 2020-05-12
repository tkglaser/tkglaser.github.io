#/bin/bash

pandoc --reference-doc=word-template.docx -o ThomasGlaserCV.docx -f markdown -t docx ThomasGlaserCV.md