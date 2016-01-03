This directory stores API keys in encrypted header files. The files can be
decrypted by placing a password in a .password file in this directory.
Obviously this is .gitignored

To encrypt:
% echo THE-PASSWORD > .password
% openssl aes-256-cbc -k `cat .password` -in CrittercismApiKey.h -out CrittercismApiKey.h.enc -a
% openssl aes-256-cbc -k `cat .password` -in GoogleAnalyticsApiKey.h -out GoogleAnalyticsApiKey.h.enc -a
% rm CrittercismApiKey.h GoogleAnalyticsApiKey.h

To decrypt:
% openssl aes-256-cbc -k `cat .password` -in CrittercismApiKey.h.enc -d -a -out CrittercismApiKey.h
% openssl aes-256-cbc -k `cat .password` -in GoogleAnalyticsApiKey.h.enc -d -a -out GoogleAnalyticsApiKey.h

