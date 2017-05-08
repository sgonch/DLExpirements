Param([String]$vmid,[String]$action)
&"C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
if($action -eq ''){$action=1}
if($vmid -eq ''){$vmid='VirtualMachine-5'}

    Connect-VIServer 192.168.0.107 -User root -Password * -Force #-Confirm:$false
    $vm=Get-VM -Id $vmid

if($action -eq 0)
{
 
}
elseif($action -ge 1)
{

    switch($action)
        {
            1 {Set-VM $vm -MemoryMB ($vm.MemoryMB+100) -Confirm:$false}
            2 {$mem=0;if($vm.NumCpu -le 100){$mem=$vm.MemoryMB}else{$mem=$vm.MemoryMB-100}; Set-VM $vm -MemoryMB $mem -Confirm:$false}
            3 {Set-VM $vm -NumCpu ($vm.NumCpu +1) -Confirm:$false}
            4 {$cpu=0;if($vm.NumCpu -eq 1){$cpu=$vm.NumCpu}else{$cpu=$vm.NumCpu-1};Set-VM $vm -NumCpu $cpu -Confirm:$false}

            #$vm.VMResourceConfiguration.CpuSharesLevel
        }
    
}

$data = @()

$hswapped=($vm | get-vmhost | get-stat -Stat mem.swapused.average -MaxSamples 15 | measure-object -Property Value -Average).Average
$hballooned=($vm | get-vmhost | get-stat -Stat mem.vmmemctl.average -MaxSamples 15 | measure-object -Property Value -Average).Average
$hready=($vm | get-vmhost | get-stat -Stat cpu.ready.summation -MaxSamples 15 | measure-object -Property Value -Average).Average
$hcostop=($vm | get-vmhost | get-stat -Stat cpu.costop.summation -MaxSamples 15 | measure-object -Property Value -Average).Average
$hread=($vm | get-vmhost | get-stat -Stat disk.numberWriteAveraged.average -MaxSamples 15 | measure-object -Property Value -Average).Average
$hwrite=($vm | get-vmhost | get-stat -Stat disk.numberReadAveraged.average -MaxSamples 15 | measure-object -Property Value -Average).Average
$hlatency=($vm | get-vmhost | get-stat -Stat disk.maxTotalLatency.latest -MaxSamples 15 | measure-object -Property Value -Average).Average

#$dhread=($vm | get-datastore | get-stat -Stat disk.numberWriteAveraged.average -MaxSamples 15 | measure-object -Property Value -Average).Average
#$drite=($vm | get-vmhost | get-stat -Stat disk.numberReadAveraged.average -MaxSamples 15 | measure-object -Property Value -Average).Average
if($vm.PowerState -ne 'PoweredOff')
{
    $ready=($vm | get-stat -Stat cpu.ready.summation -MaxSamples 15 | measure-object -Property Value -Average).Average
    $costop=($vm | get-stat -Stat cpu.costop.summation -MaxSamples 15 | measure-object -Property Value -Average).Average
    $swapped=($vm | \get-stat -Stat mem.swapped.average -MaxSamples 15 | measure-object -Property Value -Average).Average
    $ballooned=($vm | get-stat -Stat mem.vmmemctl.average -MaxSamples 15 | measure-object -Property Value -Average).Average
    $read=($vm | get-stat -Stat disk.numberWriteAveraged.average -MaxSamples 15 | measure-object -Property Value -Average).Average
    $write=($vm | get-stat -Stat disk.numberReadAveraged.average -MaxSamples 15 | measure-object -Property Value -Average).Average
    $latency=($vm | get-stat -Stat disk.maxTotalLatency.latest -MaxSamples 15 | measure-object -Property Value -Average).Average
}

$data += New-Object PSObject -Property @{
        VMId = $vmid
        HostSwapped = $hswapped
        HostBallooned = $hballooned
        HostReady = $hready
        HostCoStop = $hcostop
        HostReads = $hread
        HostWrites = $hwrite
        HostLatency = $hlatency
        Ready = $ready
        CoStop = $costop
        swapped = $swapped
        Ballooned = $ballooned
        Read = $read
        Write = $write
        Latency = $latency
        }
$filepath="c:\temp\"
$filepath+=$vmid+"-OUT.txt"
$filepath
$data | Out-File -FilePath $filepath
Disconnect-VIServer -Force -Confirm:$false