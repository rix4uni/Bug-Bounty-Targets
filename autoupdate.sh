#!/usr/bin/env bash

HEADER="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"


# PASSIVE SUBDOMAIN ENUMERATION
SUB_PASSIVE(){
for name in $(cat ~/recon/inventory/targets.json | jq -r '.targets[].name')
do
    for target in $(cat ~/recon/inventory/targets.json | jq -r ".targets[] | select(.name == \"$name\") | .domains[]")
    do
        # amass enum -passive -norecursive -noalts -d $target -config ~/.config/amass/config.ini -timeout 180 -o ~/recon/inventory/$name/${target}_amass.txt
        # cat ~/recon/inventory/$name/*amass.txt | anew ~/recon/inventory/$name/subs.txt

        # python3 ~/tools/OneForAll/oneforall.py --target $target --path ~/recon/inventory/$name/${target}_oneforall.csv run
        # cat ~/recon/inventory/$name/*oneforall.csv | sed '1d' | cut -d, -f6 | anew ~/recon/inventory/$name/subs.txt

        # subfinder -d $target -pc ~/.config/subfinder/provider-config.yaml -silent | anew ~/recon/inventory/$name/subs.txt
       	# ~/tools/SubDog/subdog -d $target | anew ~/recon/inventory/$name/subs.txt

        rm -rf ~/recon/inventory/$name/*amass.txt ~/recon/inventory/$name/*oneforall.csv
    done
done
cd ~/recon/inventory
current_time="$(date +"%a %b %d %T %Z %Y")"
eval 'git pull'
eval 'git add .'
eval 'git commit -m "Subs Update $current_time"'
eval 'git branch -M main'
eval 'git push -u origin main'
echo -e "DONE: Passive Subdomain Enumeration $current_time" | notify -silent
}
SUB_PASSIVE


# SUBDOMAIN BRUTEFORCING
SUB_BRUTE(){
for name in $(cat ~/recon/inventory/targets.json | jq -r '.targets[].name')
do
    for target in $(cat ~/recon/inventory/targets.json | jq -r ".targets[] | select(.name == \"$name\") | .domains[]")
    do
        ffuf -c -u https://FUZZ.$target -w ~/tools/2m-subdomains.txt -t 100 -v | anew ~/recon/inventory/$name/${target}_ffuf.txt
        cat ~/recon/inventory/$name/*ffuf.txt | grep "URL" | awk '{print $4}' | unfurl domains | anew ~/recon/inventory/$name/subs.txt

        puredns bruteforce ~/tools/best-dns-wordlist.txt $target -w ~/recon/inventory/$name/puredns_brute.txt -r ~/tools/resolvers.txt --resolvers-trusted ~/tools/resolvers-trusted.txt -l 0 --rate-limit-trusted 400 --wildcard-tests 30  --wildcard-batch 1500000
        puredns resolve ~/recon/inventory/$name/puredns_brute.txt -w ~/recon/inventory/$name/puredns_resolve.txt -r ~/tools/resolvers.txt --resolvers-trusted ~/tools/resolvers-trusted.txt -l 0 --rate-limit-trusted 400 --wildcard-tests 30  --wildcard-batch 1500000
        cat ~/recon/inventory/$name/puredns_resolve.txt | anew ~/recon/inventory/$name/subs.txt

        rm -rf ~/recon/inventory/$name/*ffuf.txt ~/recon/inventory/$name/puredns_brute.txt ~/recon/inventory/$name/puredns_resolve.txt
    done
done
cd ~/recon/inventory
current_time="$(date +"%a %b %d %T %Z %Y")"
eval 'git pull'
eval 'git add .'
eval 'git commit -m "Subs Update $current_time"'
eval 'git branch -M main'
eval 'git push -u origin main'
echo -e "DONE: SUBDOMAIN BRUTEFORCING $current_time" | notify -silent
}
# SUB_BRUTE


# SUBDOMAIN PROBING
SUB_ALIVE(){
for name in $(cat ~/recon/inventory/targets.json | jq -r '.targets[].name')
do
    file="$name/subs.txt"
    if [ -f "$file" ]
    then
        cat "$file" | httpx -t 100 -title -tech-detect -status-code -location -method -content-type -content-length -server -vhost -cdn -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36" -silent | anew ~/recon/inventory/$name/live-subs.txt
    fi
done
cd ~/recon/inventory
current_time="$(date +"%a %b %d %T %Z %Y")"
eval 'git pull'
eval 'git add .'
eval 'git commit -m "Live Subs Update $current_time"'
eval 'git branch -M main'
eval 'git push -u origin main'
echo -e "DONE: SUBDOMAIN PROBING $current_time" | notify -silent
}
# SUB_ALIVE


innogames(){
for target in $(cat ~/recon/inventory/targets.json | jq -r '.targets[] | select(.name == "innogames") | .domains[]')
do
    amass enum -passive -norecursive -noalts -d $target -config ~/.config/amass/config.ini -timeout 180 -o ~/recon/inventory/innogames/${target}_amass.txt
    cat ~/recon/inventory/innogames/*amass.txt | anew ~/recon/inventory/innogames/subs.txt

    python3 ~/tools/OneForAll/oneforall.py --target $target --path ~/recon/inventory/innogames/${target}_oneforall.csv run
    cat ~/recon/inventory/innogames/*oneforall.csv | sed '1d' | cut -d, -f6 | anew ~/recon/inventory/innogames/subs.txt

    subfinder -d $target -pc ~/.config/subfinder/provider-config.yaml -silent | anew ~/recon/inventory/innogames/subs.txt
    # ~/tools/SubDog/subdog -d $target | anew ~/recon/inventory/innogames/subs.txt

    #rm -rf ~/recon/inventory/innogames/*amass.txt ~/recon/inventory/innogames/*oneforall.csv

    ffuf -c -u https://FUZZ.$target -w ~/tools/2m-subdomains.txt -t 100 -v | anew ~/recon/inventory/innogames/${target}_ffuf.txt
    cat ~/recon/inventory/innogames/*ffuf.txt | grep "URL" | awk '{print $4}' | unfurl domains | anew ~/recon/inventory/innogames/subs.txt
done
}
# innogames