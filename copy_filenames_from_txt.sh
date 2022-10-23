#!/bin/bash
# TODO: bash unit testing
# Color codes for output prints
GREEN="\033[0;32m"
RED="\033[0;31m"
CYAN="\033[36m"
MAGENTA="\033[35m"
YELLOW="\033[33m"
RESET="\033[0m"
SCRIPT_VERSION="0.0.1"
############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo
   echo -e "${CYAN}Batch copy helper. Recursively search a directory for all filenames containing a sub-string based on an input file.${RESET}"
   echo -e "${CYAN}Uses an input file with each line containing a sub-string to search for.${RESET}"
   echo
   echo -e "${YELLOW}Syntax:${GREEN} $(basename $0) ${RED}[-v|h] [-f file|-d dir|-o dir]${RESET}"
   echo -e "options:"
   echo -e "${RED}-f${RESET}     ${YELLOW}File${RESET} with desired sub-strings of filenames to copy. Usually ${YELLOW}.txt${RESET}. Each search string on new line."
   echo -e "${RED}-d${RESET}     ${YELLOW}Search directory${RESET}. Will be recursively searched for any matches in ${RED}-f${RESET}. Usually ${YELLOW}./${RESET} (if cd is desired directory)."
   echo -e "${RED}-o${RESET}     ${YELLOW}Output directory${RESET}. To copy all matching files to. ${RED}Note${RESET}: will be created if does not exist."
   echo -e "${RED}-V${RESET}     Display ${YELLOW}Version${RESET} string: ${RED}$SCRIPT_VERSION${RESET}."
   echo -e "${RED}-h${RESET}     Display this ${YELLOW}Help${RESET}."
   echo -e "${RED}-v${RESET}     ${YELLOW}Verbose${RESET} prints."
   echo
}

############################################################
# CLI inputs                                               #
############################################################
while getopts "hvVf:d:o:" option;
do
    case "${option}" in
        f) SEARCH_FILE=${OPTARG};;
        d) SEARCH_DIR=${OPTARG};;
        o) OUTPUT_DIR=${OPTARG};;
        v) VERBOSE="true";;
        V) echo $SCRIPT_VERSION; exit;;
        h) 
         Help
         exit ;;
        ?)
         echo -e "${RED}Error: ${YELLOW}Invalid option${RESET}"
         exit ;;
    esac
done

if [[ -f $OUTPUT_DIR || ! -f $SEARCH_FILE || ! -d $SEARCH_DIR ]]; then
 echo -e "❌: ${RED}Inalid arguments.${YELLOW} see -h${RESET}"
 exit 1
fi

############################################################
# Main                                                     #
############################################################
mkdir -p $OUTPUT_DIR
cat $SEARCH_FILE | while read i; do
    # Handle non-matching file
    if [[ -z $(find $SEARCH_DIR -name "*$i*") && $VERBOSE ]]; then
        echo -e "❌: ${RED}$i${RESET} ||${YELLOW} No matching file found${RESET}"
        continue
    fi
    # Handle case of more than one matching file
    find $SEARCH_DIR -name "*$i*" | while read file; do
        if [[ -n "$file" ]]; then  # Check file matching
            FILENAME=$(basename ${file}); DIRNAME=$(dirname "${file}")
            if [[ -f $OUTPUT_DIR/"$FILENAME" ]]; then
                if [[ $DIRNAME/ != $OUTPUT_DIR && $VERBOSE ]]; then
                    echo -e "📁: ${CYAN}$FILENAME ${GREEN}already exists${RESET} in ${MAGENTA}$OUTPUT_DIR${RESET}"
                fi
            else
                if [[ $VERBOSE ]]; then
                    echo -e "✅: ${GREEN}$i${RESET} >> ${CYAN}$file${RESET} >> ${MAGENTA}$OUTPUT_DIR${RESET}"
                fi
                cp -r $file $OUTPUT_DIR/
            fi
        fi
    done
done
if [[ ! $VERBOSE ]]; then
    echo -e "${GREEN}Operation complete >> ${MAGENTA}$OUTPUT_DIR${RESET}"
fi
