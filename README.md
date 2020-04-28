# Azure Synapse Analytics (Data Warehouse)

Over years I work on Azure data platform and I saw data services grows exponentially. The reasons are growth, new business requirement, limitation and challenges. There are many data services from storing csv files, tabular data, nosql data, graph data, column store, key-value etc. which helps different business to choose which is best for them. On Azure there are many other service for data orchestration, processing, AI and presenting the data. If dig further on any of the terminology one can find too many options. Sometime it confuses user but i feel you choose what's best for the problem and skill set organization have. Azure provide all and covers different persona in any organization. 

Last year, Microsoft bought more capabilities to Azure SQL Data warehouse and named it as Azure synapse analytics. As of today (day I am writing this blog) it's under private preview. It's a limitless analytic services which bring data warehousing and big data analytic  capabilities together. It's beyond just seperating storage and compute.

The one feature I like most about Azure synapse is to provide one interface to design end-end data life cycle.  

# Why

Any organization who is ready to spin Azure service always curious of

    1) Are we choosing right sku for our requirement? 
    2) How performant azure service will be? 
    3) Will sku enough to handle the load? 
    4) What will be the impact on allocated resources? 
    5) How to make sure quries are performing well on DWH design? 
    6) How to build baseline matrix?  

Well, one of the ways is to monitor (and setup alerts) the service on production environment and adjust the sku. However this may impact the user experience and become hard practice to follow.

This blog post try to overcome this problem in advance to avoid any surprises on production environment. The focus will be on building a framework to simulate the load with multiple queries and get answers for above questions.

# Reference Architecture 

In this end to end architecture, we'll simulate the load from different regions with different queries. The outcome will help us understand if we choose right sku and setup good DWH design like index, cache .  

![Ref_Arch](/images/RefArch.jpg)

The key elements of the architecture :

**Azure Synapse Analytics (Data Warehouse)** : - One interface to design end to end advance analytics needs for an organization. The platform provides various options to reduce cost (SQL pool, SQL on-demand), low/no learning curve, easier to build, deploy and manage (Synapse studio). Microsoft provided great content  on Azure Synapse Analytics [here](https://docs.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/).

**Azure Virtual Machine** : - Azure virtual machine will be used to generate  actors to send request to Azure Synapse Data Warehouse.

**Power BI** : - Power BI is used as reporting tool to provide deep analysis on query execution and load metrics. Look out [here](https://powerbi.microsoft.com/en-us/) for more information about Power BI capabilities.  

**Azure Data Studio** : - A cross platform tool to query data warehouse. I like two of it's feature very much 1) source control integration 2) built-in charting capabilities of query result sets. There are more which can be found [here](https://docs.microsoft.com/en-us/sql/azure-data-studio/what-is?view=sql-server-ver15).

**Azure Machine Learning** : - Azure Machine learning make machine learning model developement, deployment, retain, tracking and manage make easier. The service provide a workspace where irrespective of your skill you can build machine learning model. You can build machine learning model using machine learning studio, notebook or auto ml. Check out more [here](https://docs.microsoft.com/en-us/azure/machine-learning/overview-what-is-azure-ml)  

**Azure Data Factory** : - A cloud based data integration service make data movement across different location with ease, fast and securely. You can build data pipeline within no time and connect to more than 90+ sources.  Please check [here](https://docs.microsoft.com/en-us/azure/data-factory/introduction) for more information.

**Azure Blob Storage** : -  

**Apache Jmeter** : - [Apache Jemter](https://jmeter.apache.org/) is a open source solution to perform load test and measure performance. Apache Jemeter is a java based 100% open source technology. Thi tool can help in generating the expected load, perform action and provide various reports to evaluate the performance of the targeted application.

**Chocolatey** : - A software management tool for Windows. Just bundle the software packages in PowerShell and deploy in any Windows environment. It's easy and fast. More more information visit [here](https://chocolatey.org/).

**Java Runtime Environment** : - Java is a programing language to build software. This technology provide libraries to build software and JRE (java runtime engine).Using JRE in this blog because Apache jemter is written on Java.

# Setting up environment

## Azure Synapse Analytics (Data warehouse)

Use [Microsoft Azure Portal](https://docs.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/create-data-warehouse-portal) or [PowerShell](https://docs.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/create-data-warehouse-powershell) to create Data warehouse. Select appropriate perfromance level (start with minimum if not sure).  

## Setup Data warehouse

Once Azure Synapse DWH is setup, next step is to setup Data warehouse design and load data. One of the ways to consider is first move metadata like table, SP, index etc creation then leverage [Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/introduction) for data movement. I am using Adventureworks dwh which is provided as a sample.  

## Download and configure Apache Jmeter

Download Apache Jmeter (version 5.2.1) from [here](http://jmeter.apache.org/download_jmeter.cgi). Unzip the downloaded folder.

By deafult Apache Jmeter don't include JDBC driver to connect to Azure Synapse Data warehouse. Let's download the JDBC driver.  

1) Download [JDBC driver](https://docs.microsoft.com/en-us/sql/connect/jdbc/system-requirements-for-the-jdbc-driver?view=sql-server-ver15)  

2) Unzip and copy **smssql-jdbc-8.2.2.jre13.jar** file 

3) Paste mssql-jdbc-8.2.2.jre13.jar file under \apache-jmeter-5.2.1\lib\

![JDBC_Lib_File](/images/SQLJDBCDriver.jpg)

## Build Java Management Extension (aka jmx) file

1) Open Apache Jmeter UI by clicking jmeter.bat under \apache-jmeter-5.2.1\bin\

![AJmeter](/images/JmeterBatch.jpg)

2) Click **Add** -> **Threads (Users)** -> **Thread Group**

![AddThread](/images/AMeterAddThread.jpg)

3) Provide **Number of Threads (users)** . Add number of users you are expecting in future. Provide **Ramp-up period (seconds)** menaing how much time Apache jmeter takes to spin up number of threads(user).  Also, provide **Loop Count** define number of times test repeat.   

![JDBC_Thread](/images/JDBCThreadConfigured.jpg)


4) Add JDBC connection. Click **Add** -> **Config Element** -> **JDBC Connection Configuration. 

![JDBC_Connection](/images/AmeterConnection.jpg)

5) Add Azure Synapse Data warehouse connection value. Provide **Variable Name for created pool** which we created in earlier step. Provide Data warehouse connection value in **Database Connection Configuration** 

![JDBC_Conn_Added](/images/JDBCConnection.jpg)

6) Create JDBC request. Righ click on thread group. Click **Add** -> **Sampler** -> **JDBC Request**. Provide **Variable Name of Pool declared...** name created in earlier step. Provide **SQL Query** to be execute against data warehouse.

![JDBC_request](/images/JDBCRequest.jpg)

7) Create report for each request execution. Let's add **View Results Tree**

![Add_report](/images/AddResult.jpg)

8) Create multiple JDBC request (with different queries). A sample jmx file is located at \Scripts\SampleLoadDef.jmx. Also sql query are located at \Scripts\SampleQuery.txt 

## Move scripts to Azure storage

Let's move artefacts in Azure blob storage. Do sequentially.

1. Create Azure blob storage and three container under it. **1) AJmeter** to store Apache Jmeter package. **2) loadtestdef** to store script file and **3) scripts**.

![Storage](/images/StorageContainer.jpg)

2. AJmeter:- Use [azcopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10) to move Apache Jmeter from local drive to Azure blob storage. 

![Jmeter_Storage](/images/StorageAJmeter.jpg)

3. Copy jmx files created in earlier steps under **loadtestdef** container.

![JmxStorage](/images/JMXStorage.jpg)

**Note**:- Load test scripts which will be executed from East US and West US

4. Upload below PowerShell script in **scripts** container. Below scripts will be executed in order once Azure VM is created.  

    4.1 **swinstall1.ps1**:- File store under .\Scripts\. This script will install chocolatey software management tool in VM. Once chocolatey installed sucecssfully then it will call next script. 

        ```powershell

            Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
        
            .\swInstall2.ps1
        ```
 
    4.2 **swinstall2.ps1**:- File store under .\Scripts\. This script will install openjdk. SQL JDBC driver needs Java 14 runtime hence install openjdk. Next is to install azcopy (version 10). Once installtion completed succesfully them it will call next script. 

        ```powershell

            Set-ExecutionPolicy Bypass -Scope Process -Force;
            choco feature enable -n=allowGlobalConfirmation;
            choco install openjdk -y;
            choco install azcopy10 -y;
        
            .\MoveAJmeter.ps1
        ```

    **4.3** MoveAJmeter.ps1:- File store under .\Scripts\. This script will copy Apache Jmeter from Axure Blob storage to C drive in Azure VM. Once package is copied it will call next script.  

        ```powershell

            azcopy copy "https://XXXXXXX.blob.core.windows.net/ajmeter?SHARED_ACCESS_SIGNATURE" "C:\" --recursive=true ;
            
            .\Moveloadtest.ps1
        ```

    **4.4** Moveloadtest.ps1:- File store under .\Scripts\. This script will copy 

        ```powershell

            azcopy copy "https://XXXXX.blob.core.windows.net/loadtestdef/EastLoadDefinition.jmx?SHARED_ACCESS_SIGNATURE" "C:\ajmeter\apache-jmeter-5.2.1\bin" --recursive=true ;
            
            azcopy copy "https://XXXXX.blob.core.windows.net/loadtestdef/WestLoadDefinition.jmx?SHARED_ACCESS_SIGNATURE" "C:\ajmeter\apache-jmeter-5.2.1\bin" --recursive=true ;  
        ```

![Scripts_storage](/images/Script_Storage.jpg)

## Execute work load

The next step is to setup Azure VM in different regions, install software, configure, manage file and execute the work load. Copy folder **ClientSide_Scripts** on local drive. This folder contains two **jmx** file assuming to run workload from two regions (East and West). If you want to run load from multiple region then change in the below script and execute it seperatly. Soon I will automate this as well. 

Below is the extract from **.\ClientSide_Scripts\ExecuteScriptMain.ps1** file.

    ```powershell
    
    <# Block 1 :- Connet to Azure Subscription #>
        Connect-AzAccount
        Add-AzureAccount <#Selet account if you have multiple accounts in one subscription#> 
    <# End of Block 1 #>

    <# Block 2 :- Create a New VM on Azure #>
        $ResourceGroupName ="XXXXXXXXX"
        $VMName = "XXXXXXXXXXX"
        $VMLocation = "EastUS"
        $VMSize = "Standard_F32s_v2" #Check for other VM sizes on Azure https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes
        $VMUsername="XXXXXXXX"
        $VMPassword=ConvertTo-SecureString Password@123 -AsPlainText -Force
        $VirtualNetworkName = "XXXXXXXVnet"
        $SubnetName = "XXXXXXXXXXX"
        $PublicIpAddress="XXXXXXXXXXXXXXXX"
        $SecurityGroupName = "XXXXXXXXXXX"
        $ImageName = "MicrosoftWindowsDesktop:Windows-10:19h1-pro-gensecond:18362.720.2003120536"

        New-AzVm `
                -ResourceGroupName $ResourceGroupName `
                -Name $VMName `
                -Location $VMLocation `
                -VirtualNetworkName $VirtualNetworkName `
                -SubnetName $SubnetName `
                -SecurityGroupName $SecurityGroupName `
                -PublicIpAddressName $PublicIpAddress `
                -Image $ImageName `
                -Credential $cred `
                -OpenPorts 3389             
    <# End of Block 2 #>


    <# Block 3 :- Install and configure software #>
        $StorageAccountName= "XXXXXXXXXXX" 
        $StorageAccountKey= "XXXXXXXXXXXXXXXXXXXXXXXXXX"
        $fileUri = @("https://XXXXXXX.blob.core.windows.net/scripts/swInstall1.ps1",
        "https://XXXXXXXXXXX.blob.core.windows.net/scripts/swInstall2.ps1",
        "https://XXXXXXXXXXXX.blob.core.windows.net/scripts/MoveAJmeter.ps1",
        "https://XXXXXXXXXXXXXX.blob.core.windows.net/scripts/Moveloadtest.ps1")

        $settings = @{"fileUris" = $fileUri};
        $VMLocation = "East US"
        $protectedSettings = @{"storageAccountName" = $storageAcctName; "storageAccountKey" = $storageKey; "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File swInstall1.ps1"};
        Set-AzVMExtension -ResourceGroupName $ResourceGroupName `
        -Location $VMLocation `
        -VMName $VMName `
        -Name "SetupLoadMachine" `
        -Publisher "Microsoft.Compute" `
        -ExtensionType "CustomScriptExtension" `
        -TypeHandlerVersion "1.10" `
        -Settings $settings    `
        -ProtectedSettings $protectedSettings

    <# End of Block 3 #>

    <# Block 4 Restart VM after s/w installation  #> 
        Restart-AzVM -ResourceGroupName $ResourceGroupName -Name  $VMName
    <# End of Block 4 #> 

    <# Block 5 :- invoke script #> 
        Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -VMName $VMName -CommandId 'RunPowerShellScript' -ScriptPath 'LOCAL_DRIVE:\ClientSide_Scripts\EastRunloadtest.ps1' 
    <# End of Block 5 #>

    <# OPTIONAL Remove Resource Group Once perf testing is done.#> 
    Remove-AzResourceGroup -Name "sudhirawDWH"
    <# END #>

    ```
Once Azure VM is setup and software is configured. Below is the screenshot of files copied.

![File_Copied](/images/fileCopied.jpg)

Below is the screenshot of Java installed on VM

![JRE_VM](/images/JREinVM.jpg)

And request started coming in...

![Load_coming](/images/LoadStarted.jpg)

Over the period of time...

![Execution](/images/QueryExecutionStatus.jpg)

VM cpu usage....

![VM_CPU](/images/CPU_VM.jpg)

Data warehouse unit usgae....

![DWU](/images/DWU.jpg)

Powershell script execution ends...

![PWScripts](/images/PowerShellOutput.jpg)




# Analyse the Test Results

## Investigate result over dashboard  

Notice all queries executes under smallrc. This is a default resource class in Azure Synapse Data warehouse. The memory allocation for smallrc is 25% (based on the service level). More information about setting up different resource class is explained [here](https://docs.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/resource-classes-for-workload-management). This way we can associate different member (based on priority or role in organnization) in different resource class.

![Workgroup_Allocation](/images/ResourceAllocation.jpg)


## Analyse in PBI

## Anomaly detection