KillMail usage:
**************
KillMailUser (LDAP servername) (User DN)


For example:
KillMailUser MY-DC-01 "CN=Bob Smith,CN=Users,DC=exutils,DC=com"



Notes:
*****
1.  This tool removes all mail attributes for an individual user object (supplied by the user)


2.  Any spaces in the DN have to be encapsulated in quotes.  For example:

    "CN=Bob Smith,OU=My Test OU,DC=exutils,DC=com"


3.  List of attributes removed:

"deliverAndRedirect",
"homeMDB",
"homeMTA",
"mail",
"legacyExchangeDN",
"proxyAddresses",
"showInAddressBook",
"msExchADCGlobalNames",
"mailNickname",
"replicatedObjectVersion",
"replicationSignature",
"targetAddress",
"msExchMailboxSecurityDescriptor",
"dLMemDefault",
"textEncodedORAddress",
"mAPIRecipient",
"mDBUseDefaults",
"msExchALObjectVersion",
"msExchHideFromAddressLists",
"msExchHomeservername",
"msExchMailboxGuid",
"msExchPoliciesIncluded",
"msExchPreviousAccountSid",
"msExchUnmergedAttsPt",
"msExchUserAccountControl",
"msExchMasterAccountSid"

