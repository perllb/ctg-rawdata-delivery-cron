# ctg-rawdata-delivery-cron
Cron-script for automatic delivery of ctg-rawdata projects

- Detects runfolders (in nas-sync/upload) with `CTG_SampleSheet.rawdata.csv` file within 
- Creats lfs603 user for the project and generates delivery email - which will be sent to customer if `autodeliver,y` set in the samplesheet (see below).

## USAGE

1. Run `bash ctg-rawdata-cron.sh` to scan nas-sync/upload for run folders with CTG_SampleSheet.rawdata.csv)
2. If the script above finds a new rawdata project ready to deliver, it will start delivery (via `rawdata-crondriver`)

#### Crontab for automatic scanning (in this case every minute):
`*/1 * * * *  /bin/bash ${CRONDIR}/ctg-rawdata-cron/ctg-rawdata-cron.sh >> ${CRONDIR}/ctg-rawdata-cron/cron.rawdata.log 2>&1`

## Input Files

The following files must be in the runfolder to start delivery:

1. Samplesheet (CTG_SampleSheet.**rawdata**.csv) (See required format and content below)
2. ctg-interop folder (ctg-interop must have been run)
3. ctg.sync.done (the transfer of runfolder must have been completed)
4. Also, when the delivery starts, it will add ctg.rawdata.start - if this is found, the delivery is cancelled.

### Samplesheet requirements:

Note: One samplesheet pr project!
Note: Must be in comma-separated values format (.csv)

| email | customer.email@med.lu.se;customer2.email@med.lu.se | 
| projid | 2022_121 | 
| cc | ctg.lab@med.lu.se | 
| autodeliver | y | 

- `email` : Email to customer. If more than one, separate with ";" 
- `projid` : Project ID. E.g. 2021_033, 2021_192. This will be used to create the lfs user
- `cc` : emails to add as CC in mail - typically CTG lab personel. 
- `autodeliver` : Set to 'y' if the customer should recieve delivery email! If not 'y', then it will transfer data to lfs, and create the email, but it will only be sent to ctg-staff.  

### Samplesheet template (.csv)

#### Name : `CTG_SampleSheet.rawdata.csv`

##### This will send delivery mail to customer
```
email,customer@med.lu.se;customer2@med.lu.se
projid,2022_999
cc,ctg.staff1@med.lu.se
autodeliver,y
``` 
##### This will send delivery mail only to ctg-staff (and ctg-bioinformatician)
```
email,customer@med.lu.se;customer2@med.lu.se
projid,2022_999
cc,ctg.staff1@med.lu.se
autodeliver,n
``` 

