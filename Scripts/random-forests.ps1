pushd "C:\Program Files\Weka-3-8\"
Get-Variable -Exclude PWD,*Preference | Remove-Variable -EA 0

# Similar to the J48 script

# Defines the training and testing filenames

$train = "optraining + 1900"
$test = "optesting - 1900"

$name = "900"

# Defines the minimum number of instances per leaf to test to
$n_instances = 2000

# Creates directories to outout the experimental results

New-Item "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Decision trees\random-forest\${name}" -type directory >$null

New-Item "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Decision trees\random-forest\${name}\cv" -type directory >$null
New-Item "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Decision trees\random-forest\${name}\cv\attributes" -type directory >$null
New-Item "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Decision trees\random-forest\${name}\cv\min" -type directory >$null
New-Item "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Decision trees\random-forest\${name}\cv\models" -type directory >$null

New-Item "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Decision trees\random-forest\${name}\test set" -type directory >$null
New-Item "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Decision trees\random-forest\${name}\test set\attributes" -type directory >$null
New-Item "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Decision trees\random-forest\${name}\test set\min" -type directory >$null
New-Item "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Decision trees\random-forest\${name}\test set\models" -type directory >$null


$input_path = "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\arff"
$output_path = "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Decision trees\random-forest\${name}\cv"
$output_path_test = "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Decision trees\random-forest\${name}\test set"

# Performs the experiments, iterating through a range of parameters as needed

Write-Host "Cross Validation: Benchmark"

java -cp weka.jar weka.classifiers.trees.RandomForest -t "${input_path}/${train}.arff" -x 10 -P 100 -I 100 -num-slots 0 -K 0 -M 1.0 -V 0.001 -S 1 -d "${output_path}\models\break-ties.model" > "${output_path}\benchmark.txt"

Write-Host "Cross Validation: Break ties randomly"

java -cp weka.jar weka.classifiers.trees.RandomForest -t "${input_path}\${train}.arff" -B -x 10 -P 100 -I 100 -num-slots 0 -K 0 -M 1.0 -V 0.001 -S 1 -d "${output_path}\models\break-ties.model" > "${output_path}\break-ties.txt"

Write-Host "Cross Validation: Varying attributes"
For ($i = 1; $i -le 64; $i++){
    Write-Host "${i}"
    java -cp weka.jar weka.classifiers.trees.RandomForest -t "${input_path}\${train}.arff" -x 10 -P 100 -I 100 -num-slots 0 -K ${i} -M 1.0 -V 0.001 -S 1 -d "${output_path}\models\a(${i}).model" | Out-File "${output_path}\attributes\a(${i}).txt" -Encoding ASCII
}

Remove-Item "${output_path}/attributes/collected_att_output.txt"
For($i = 1; $i -le 64; $i++){
    Write-Host "Cross Validation: Extracting attributes ${i}..."
    $result = Select-String -Path "$output_path/attributes/a(${i}).txt" -Pattern "=== Stratified cross-validation ===" -Context 0,3
    Add-Content "$output_path/attributes/collected_att_output.txt" "`n${result}"

}

$regex = "Correctly Classified Instances(.*)"
Select-String -Path "$output_path/attributes/collected_att_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "$output_path/attributes/correct_instances.txt"


Write-Host "Cross Validation: Range of min"

For($i = 0; $i -le ${n_instances}; $i = ${i} + ${n_instances}/10){
    java -cp weka.jar weka.classifiers.trees.RandomForest -t "${input_path}\${train}.arff" -x 10 -P 100 -I 100 -num-slots 0 -K 0 -M ${i} -V 0.001 -S 1 -d "${output_path}\models\min-${i}.model" | Out-File -FilePath "$output_path/min/min-${i}.txt" -Encoding ASCII
    Write-Host "$i"
}

Remove-Item "${output_path}/min/collected_min_output.txt"
For($k = 0; $k -le ${n_instances}; $k = $k + ${n_instances}/10){
    Write-Host "Cross Validation: Extracting min ${k}..."
    $result = Select-String -Path "$output_path/min/min-${k}.txt" -Pattern "=== Stratified cross-validation ===" -Context 0,3
    Add-Content "$output_path/min/collected_min_output.txt" "`n${result}"

}

$regex = "Correctly Classified Instances(.*)"
Select-String -Path "${output_path}\min\collected_min_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${output_path}\min\correct_instances.txt"

 
Write-Host "On Test Set: Benchmark"

java -cp weka.jar weka.classifiers.trees.RandomForest -t "${input_path}\${train}.arff" -T "${input_path}\${test}.arff" -P 100 -I 100 -num-slots 0 -K 0 -M 1.0 -V 0.001 -S 1 -d "${output_path_test}\models\benchmark.model" > "${output_path_test}\benchmark.txt"

Write-Host "On Test Set: Break ties randomly"

java -cp weka.jar weka.classifiers.trees.RandomForest -t "${input_path}\${train}.arff" -T "${input_path}\${test}.arff" -P 100 -I 100 -num-slots 0 -K 0 -M 1.0 -V 0.001 -S 1 -d "${output_path_test}\models\break-ties.model" > "${output_path_test}\break-ties.txt"


Write-Host "On Test Set: Varying attributes"
For ($i = 1; $i -le 64; $i++){
    Write-Host "${i}"
    java -cp weka.jar weka.classifiers.trees.RandomForest -t "${input_path}\${train}.arff" -T "${input_path}\${test}.arff" -P 100 -I 100 -num-slots 0 -K ${i} -M 1.0 -V 0.001 -S 1 -d "${output_path_test}\models\a(${i}).model" | Out-File "${output_path_test}\attributes\a(${i}).txt" -Encoding ASCII
}

Remove-Item "${output_path_test}/attributes/collected_att_output.txt"
For($i = 1; $i -le 64; $i++){
    Write-Host "On Test Set: Extracting attributes ${i}..."
    $result = Select-String -Path "${output_path_test}/attributes/a(${i}).txt" -Pattern "=== Error on test data ===" -Context 0,3
    Add-Content "${output_path_test}/attributes/collected_att_output.txt" "`n${result}"

}

$regex = "Correctly Classified Instances(.*)"
Select-String -Path "${output_path_test}/attributes/collected_att_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${output_path_test}/attributes/correct_instances.txt"


Write-Host "On Test Set: Range of min"

For($i = 0; $i -le ${n_instances}; $i = ${i} + ${n_instances}/10){
    java -cp weka.jar weka.classifiers.trees.RandomForest -t "${input_path}\${train}.arff" -T "${input_path}\${test}.arff" -P 100 -I 100 -num-slots 0 -K 0 -M ${i} -V 0.001 -S 1 -d "${output_path_test}\models\min-${i}.model" | Out-File -FilePath "$output_path_test/min/min-${i}.txt" -Encoding ASCII
    Write-Host "$i"
}

Remove-Item "${output_path_test}/min/collected_min_output.txt"
For($k = 0; $k -le ${n_instances}; $k = $k + ${n_instances}/10){
    Write-Host "On Test Set: Extracting min ${k}..."
    $result = Select-String -Path "$output_path_test/min/min-${k}.txt" -Pattern "=== Error on test data ===" -Context 0,3
    Add-Content "${output_path_test}/min/collected_min_output.txt" "`n${result}"
    "${output_path_test}/min/collected_min_output.txt".close
}

$regex = "Correctly Classified Instances(.*)"
Select-String -Path "${output_path_test}\min\collected_min_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${output_path_test}/min/correct_instances.txt"

[console]::beep(500,300)
[console]::beep(750,750)

popd