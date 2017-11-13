#!/usr/bin/env bash
#
# Build for interactive use, i. e. set PATH accordingly if run via cron
#
# Read as206946-hosts.txt and generate a matrix of connections, then add as206946-links.txt
# to generate as206946-tunnel.txt

ASN=$(pwd | awk '{print substr($0, index($0, "/AS")+3);}')

awk < as${ASN}-hosts.txt >/tmp/tunnel-$$.tmp '{host[++num]=$1;} END {for(i=1; i<=num; i++) { for(j=i; j<=num; j++) {if(host[i] != host[j]) printf("%s:%s l2tp\n", host[i], host[j]);}}}'
#cat /tmp/tunnel-$$.tmp as206813-links.txt | sort -u >as206813-tunnel.txt
cat /tmp/tunnel-$$.tmp | awk -v ASN=${ASN} 'BEGIN {numlinks=0; linksfile=sprintf("as%s-links.txt", ASN); while((getline line <linksfile) > 0) {n=split(line, fields); if(n==2) {print line; split(fields[1], peers, ":"); link[numlinks++]=sprintf("%s:%s", peers[1], peers[2]); link[numlinks++]=sprintf("%s:%s", peers[2], peers[1]);}} /* printf("# %d links read from %s\n", numlinks, linksfile); */} {lnk=$1; tpe=$2; found=0; for(i=0; i<numlinks && found==0; i++) {if(lnk==link[i]) {found=1; /* printf("%s matches %s\n", lnk, link[i]); */}} if(found==0) {printf("%s\n", $0);}}' | sort -u >as${ASN}-tunnel.txt
rm /tmp/tunnel-$$.tmp
