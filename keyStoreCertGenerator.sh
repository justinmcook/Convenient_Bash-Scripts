#!/bin/bash

counter=0

echo "keystore or truststore?"
read keyOrTrust
echo "What is the name of the store (not including anything after .)?"
read keyOrTrustStore
echo "What is the password?"
read keyOrTrustStorePassword

if [ $keyOrTrust == "keystore" ]
then
	rm "$keyOrTrustStore"KeyStoreHumanReadable.txt
	certNames=`keytool -list -keystore "$keyOrTrustStore".keystore -storepass "$keyOrTrustStorePassword" 2>/dev/null | grep -E 'PrivateKeyEntry|trustedCertEntry' | cut -d' ' -f1 | rev | cut -c 2- | rev`
	while read -r line; do
		echo ------------------------ Certificate "$counter" of "$keyOrTrustStore".keystore ------------------------ >> "$keyOrTrustStore"KeyStoreHumanReadable.txt
		echo "Alias for given certificate is: $line" >> "$keyOrTrustStore"KeyStoreHumanReadable.txt
		echo $'\n' >> "$keyOrTrustStore"KeyStoreHumanReadable.txt
		keytool -exportcert -alias "$line" -keystore "$keyOrTrustStore".keystore -file temp.txt -storepass "$keyOrTrustStorePassword" 2>/dev/null
		keytool -printcert -file temp.txt >> "$keyOrTrustStore"KeyStoreHumanReadable.txt 2>/dev/null
		echo ---------------------- End certificate "$counter" of "$keyOrTrustStore".keystore ---------------------- >> "$keyOrTrustStore"KeyStoreHumanReadable.txt
		echo $'\n\n\n' >> "$keyOrTrustStore"KeyStoreHumanReadable.txt
		counter=$[counter + 1]
	done <<< "$certNames"
	rm temp.txt
elif [ $keyOrTrust == "truststore" ]
then
	rm "$keyOrTrustStore"TrustStoreHumanReadable.txt
	certNames=`keytool -list -keystore "$keyOrTrustStore".truststore -storepass "$keyOrTrustStorePassword" 2>/dev/null | grep -E 'PrivateKeyEntry|trustedCertEntry' | rev | cut -c 33- | rev`
	while read -r line; do
		echo ------------------------ Certificate "$counter" of "$keyOrTrustStore".truststore ------------------------ >> "$keyOrTrustStore"TrustStoreHumanReadable.txt
		echo "Alias for given certificate is: $line" >> "$keyOrTrustStore"TrustStoreHumanReadable.txt
		echo ---------------------- End certificate "$counter" of "$keyOrTrustStore".keystore ---------------------- >> "$keyOrTrustStore"TrustStoreHumanReadable.txt
		echo $'\n\n\n' >> "$keyOrTrustStore"TrustStoreHumanReadable.txt
		counter=$[counter + 1]
	done <<< "$certNames"
fi
