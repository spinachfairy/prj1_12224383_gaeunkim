#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Usage: $0 file1 file2 file3"
    exit 1
fi

file1="$1"
file2="$2"
file3="$3"

echo "************OSS1 - Project1************"
echo "*        StudentID : 12224383         *"
echo "*          Name : Gaeun Kim           *"
echo "***************************************"

while true; do
    echo -e "\n[MENU]"
    echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
    echo "2. Get the team data to enter a league position in teams.csv"
    echo "3. Get the Top-3 Attendance matches in matches.csv"
    echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
    echo "5. Get the modified format of date_GMT in matches.csv"
    echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
    echo "7. Exit"
    read -p "Enter your CHOICE (1~7) : " CHOICE

    if [ $CHOICE -eq 1 ]; then
        read -p "Do you want to get the Heung-Min Son's data? (y/n) : " ANSWER

        if [ $ANSWER = "y" ]; then
            cat "$file2" | awk -F ',' '$1=="Heung-Min Son" {printf "Team:%s, Appearance:%d, Goal:%d, Assist:%d\n", $4, $6, $7, $8}'
        fi

    elif [ $CHOICE -eq 2 ]; then
        read -p "What do you want to get the team data of league_position[1~20] :" POS

        if [ $POS -gt 0 ] && [ $POS -lt 21 ]; then
            cat "$file1" | awk -F ',' -v POS="$POS" '$6==POS {printf "%s %s %f\n", POS, $1, $2/($2+$3+$4)}'
        fi

    elif [ $CHOICE -eq 3 ]; then
        read -p "Do you want to know Top-3 attendance data? (y/n) : " ANSWER

        if [ $ANSWER = "y" ]; then
            echo "***Top-3 Attendance Match***"
            cat "$file3" | sort -t',' -r -k 2 -n | head -n 3 | awk -F ',' '{print "\n" $3 " vs " $4 " (" $1 ")\n" $2 " " $7}'
        fi

    elif [ $CHOICE -eq 4 ]; then
        read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " ANSWER

        if [ $ANSWER = "y" ]; then
            IFS=,
            cat "$file1" | awk -F ',' '{print $1 "," $6}' | sort -t',' -k 2 -n | while read -r team rank; do
                echo -e "\n$rank $team"
                cat "$file2" | awk -F ',' -v team="$team" '$4==team {print $1 "," $7}' |
                sort -t',' -r -k 2 -n | head -n 1 |
                awk -F ',' '{print $1 " " $2}'
            done
        fi

    elif [ $CHOICE -eq 5 ]; then
        read -p "Do you want to modify the format of date? (y/n) : " ANSWER

        if [ $ANSWER = "y" ]; then
            cat "$file3" | awk -F ',' 'NR!=1 && NR<12 {print $1}' | sed -E 's/ - / /' |
            sed 's/Aug /08 /' |
            sed 's/Sep /09 /' |
            sed 's/Oct /10 /' |
            sed 's/Nov /11 /' |
            sed 's/Dec /12 /' |
            sed 's/Jan /01 /' |
            sed 's/Feb /02 /' |
            sed 's/Mar /03 /' |
            sed 's/Apr /04 /' |
            sed 's/May /05 /' |
            sed -E 's/([0-9]{2}) ([0-9]{2}) ([0-9]{4}) ([0-9]+:[0-9]+[a-z]m)/\3 \1 \2 \4/' |
            sed -E 's/\s/\//g' | sed -E 's/\// /3'
        fi

    elif [ $CHOICE -eq 6 ]; then
        echo "1) Arsenal                     11) Liverpool"
        echo "2) Tottenham Hotspur           12) Chelsea"
        echo "3) Manchester City             13) West Ham United"
        echo "4) Leicester City              14) Watford"
        echo "5) Crystal Palace              15) Newcastle United"
        echo "6) Everton                     16) Cardiff City"
        echo "7) Burnley                     17) Fulham"
        echo "8) Southampton                 18) Brighton & Hove Albion"
        echo "9) AFC Bournemouth             19) Huddersfield Town"
        echo "10) Manchester United          20) Wolverhampton Wanderers"
        read -p "Enter your team number : " ANSWER

        if [ $ANSWER -gt 0 ] && [ $ANSWER -lt 21 ]; then
            TEAM=$(cat "$file1" | awk -F ',' -v num="$((ANSWER+1))" 'NR==num {print $1}')

            cat "$file3" | awk -F ',' -v team="$TEAM" 'NR>1 && $3==team {print $1 "," (($5-$6)) "," $3 "," $5 "," $6 "," $4}' |
            sort -t',' -r -k 2 -n |
            awk -F ',' '
                NR==1 {largest=$2}
                largest<=0 {exit}
                $2==largest {print "\n" $1 "\n" $3 " " $4 " vs " $5 " " $6}'
        fi

    elif [ $CHOICE -eq 7 ]; then
        echo -e "Bye!\n"
        exit
    fi
done
