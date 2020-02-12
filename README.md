# MinION Monitor

*So you have a Oxford Nanopore MinION sequencer (yay!)*  
**BUT**  
*You want to run it using a computer that doesn't quite meet ONT's standards?*  

For example:
  
* Your computer's SSD is too small to handle all the data output by a run, but either:
	1. You have a large external hard drive
	2. You have remote storage (and quick internet)
* You don't have a GPU on board to do basecalling, but either
	1. You have access to a server with a GPU 
	2. You have access to a computer cluster with a GPU

**Then perhaps this software can help!**

## 1. Description:
MinION Monitor is a program that will perform remote tasks with fast5 files produced during a MinION sequencing run. There are two template scripts that provide examples and can be modified to work with your system:
  
1. `minion_monitor.sh`: Monitors MinKNOW output and moves fast5 files to an attached external hard drive
2. `minion_monitor_basecall.sh`: Monitors MinKNOW output, moves fast5 files to an attached external hard drive and to a compute cluster. With the `auto_basecall.sh` script, automatically initiates guppy basecalling of batches of fast5 files

## 2. Requirements:

* Ubuntu Linux or Mac OSX (will probably work on Windows, but not tested)
* [fswatch](https://github.com/emcrisostomo/fswatch)
	* Mac: `brew install fswatch`
	* Ubuntu `sudo apt-get install fswatch`
* [rsync](https://rsync.samba.org)

## 3. Installation:
1. Download
2. These scripts WILL NOT work without modification for your setup. 

	* Open with a text editor or `nano` 
	* Edit the variables at the top of the script to point to the full paths of your MinKNOW output directory, your external hard drive, and/or your remote server / compute cluster
3. If you are using a remote server / compute cluster, it will have to be accessible by ssh and will need to have your public ssh key in its `authorized_keys` file. Do some googling or send me an email if you need help with that.
4. If you want to do remote basecalling via the `minion_monitor_basecall.sh` script, you will need to modify the `auto_basecall.sh` script to match your job scheduling software (i.e. Slurm, SGE, etc.) and account info. Then save the script to the remote server and modify `minion_monitor_basecall.sh` to include the full path.
5. Make the script(s) executable:  
```
chmod 755 minion_monitor.sh
```  
or  
```
chmod 755 minion_monitor_basecall.sh
```

##4. Usage:
1. Plug in your external drive
2. Open a terminal window
3. Run the script, i.e. `./minion_monitor.sh` or `bash minion_monitor.sh`. Make sure not to close this window.
4. Start MinKNOW, make new experiment, start experiment
5. The script will automatically detect your experiment (after the device has reached temperature) and move files as soon as they are generated. 
6. When you are finished with the experiment, bring the terminal window to the front and hit 'Cntrl-C'. If you are doing remote basecalling, this will trigger the basecaller to start running the last batch of fast5 files.

**That's it!** Feel free to modify as needed for your purposes. If you have questions, send me a message through GitHub. Hope I've been able to save you some time and trouble. 
 
