pushd "C:\Program Files\Weka-3-8\"
Get-Variable -Exclude PWD,*Preference | Remove-Variable -EA 0

# These variables have to be changed to match taht of the desired training/test sets and input/output paths

$train = "optraining + 1900"
$test = "optesting - 1900"

$name = "1900"
$n_instances = 2000

$input_path = "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\arff"
$output_path = "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Decision trees\j48\${name}\cv"
$output_path_test = "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Decision trees\j48\${name}\test set"

# Begin testing. Iterates through a range of parameters as needed.

Write-Host "Cross Validation: Benchmark"

java -cp weka.jar weka.classifiers.trees.J48 -t "${input_path}\${train}.arff" -x 10 -C 0.25 -M 2 -d "${output_path}\models\benchmark.model" > "${output_path}\benchmark.txt"

Write-Host "Cross Validation: Binary Split"

java -cp weka.jar weka.classifiers.trees.J48 -t "${input_path}\${train}.arff" -x 10 -C 0.25 -B -M 2 -d "${output_path}\models\binary-split.model" > "${output_path}\binary-split.txt"

Write-Host "Cross Validation: Unpruned"

java -cp weka.jar weka.classifiers.trees.J48 -t "${input_path}\${train}.arff" -x 10 -U -M 2 -d "${output_path}\models\unpruned.model" > "${output_path}\unpruned.txt"



Write-Host "Cross Validation: Varying confidence"
For ($i = 0.1; $i -le 0.5; $i = $i + 0.05){
    Write-Host "${i}"
    java -cp weka.jar weka.classifiers.trees.J48 -t "${input_path}\${train}.arff" -x 10 -C ${i} -M 2 -d "${output_path}\models\c(${i}).model" > "${output_path}\confidence\c(${i}).txt"
}

Remove-Item "${output_path}/confidence/collected_con_output.txt"
For($i = 0.1; $i -le 0.5; $i = $i + 0.05){
    Write-Host "Cross Validation: Extracting confidence ${i}..."
    $result = Select-String -Path "$output_path/confidence/c(${i}).txt" -Pattern "=== Stratified cross-validation ===" -Context 0,3
    Add-Content "$output_path/confidence/collected_con_output.txt" "`n${result}"

}

$regex = "Correctly Classified Instances(.*)"# [-+]?[0-9]\.?[0-9]+      %"
Select-String -Path "$output_path/confidence/collected_con_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "$output_path/confidence/correct_instances.txt"


Write-Host "Cross Validation: Range of min"

For($i = 0; $i -le ${n_instances}; $i = ${i} + ${n_instances}/10){
    java -cp weka.jar weka.classifiers.trees.J48 -t "${input_path}\${train}.arff" -x 10 -C 0.25 -M ${i} -d "${output_path}\models\min-${i}.model" > "$output_path/min/min-${i}.txt"
    Write-Host "$i"
}

Remove-Item "$output_path/min/collected_min_output.txt"
For($k = 0; $k -le ${n_instances}; $k = ${k} + ${n_instances}/10){
    Write-Host "Cross Validation: Extracting min ${k}..."
    $result = Select-String -Path "$output_path/min/min-${k}.txt" -Pattern "=== Stratified cross-validation ===" -Context 0,3
    Add-Content "$output_path/min/collected_min_output.txt" "`n${result}"

}

$regex = "Correctly Classified Instances(.*)"
Select-String -Path "$output_path/min/collected_min_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${output_path}/min/correct_instances.txt"



Write-Host "On Test Set: Benchmark"

java -cp weka.jar weka.classifiers.trees.J48 -t "${input_path}\${train}.arff" -T "${input_path}\${test}.arff" -C 0.25 -M 2 -d "${output_path_test}\models\benchmark.model" > "${output_path_test}\benchmark.txt"

Write-Host "On Test Set: Binary Split"

java -cp weka.jar weka.classifiers.trees.J48 -t "${input_path}\${train}.arff" -T "${input_path}\${test}.arff" -C 0.25 -B -M 2 -d "${output_path_test}\models\binary-split.model" > "${output_path_test}\binary-split.txt"

Write-Host "On Test Set: Unpruned"

java -cp weka.jar weka.classifiers.trees.J48 -t "${input_path}\${train}.arff" -T "${input_path}\${test}.arff" -U -M 2 -d "${output_path_test}\models\unpruned.model" > "${output_path_test}\unpruned.txt"



Write-Host "On Test Set: Varying confidence"
For ($i = 0.1; $i -le 0.5; $i = $i + 0.05){
    Write-Host "${i}"
    java -cp weka.jar weka.classifiers.trees.J48 -t "${input_path}\${train}.arff" -T "${input_path}\${test}.arff" -C ${i} -M 2 -d "${output_path_test}\models\c(${i}).model" > "${output_path_test}\confidence\c(${i}).txt"
}

Remove-Item "${output_path_test}/confidence/collected_con_output.txt"
For($i = 0.1; $i -le 0.5; $i = $i + 0.05){
    Write-Host "On Test Set: Extracting confidence ${i}..."
    $result = Select-String -Path "${output_path_test}\confidence\c(${i}).txt" -Pattern "=== Error on test data ===" -Context 0,3
    Add-Content "${output_path_test}/confidence/collected_con_output.txt" "`n${result}"

}

$regex = "Correctly Classified Instances(.*)"
Select-String -Path "$output_path_test/confidence/collected_con_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "$output_path_test/confidence/correct_instances.txt"



Write-Host "On Test Set: Range of min"

For($i = 0; $i -le ${n_instances}; $i = ${i} + ${n_instances}/10){
    java -cp weka.jar weka.classifiers.trees.J48 -t "${input_path}\${train}.arff" -T "${input_path}\${test}.arff" -C 0.25 -M ${i} -d "${output_path_test}\models\min-${i}.model" > "$output_path_test/min/min-${i}.txt"
    Write-Host "$i"
}

Remove-Item "$output_path_test/min/collected_output.txt"
For($k = 0; $k -le ${n_instances}; $k = ${k} + ${n_instances}/10){
    Write-Host "On Test Set: Extracting min ${k}..."
    $result = Select-String -Path "$output_path_test/min/min-${k}.txt" -Pattern "=== Error on test data ===" -Context 0,3
    Add-Content "$output_path_test/min/collected_output.txt" "`n${result}"

}

$regex = "Correctly Classified Instances(.*)"# [-+]?[0-9]\.?[0-9]+      %"
Select-String -Path "$output_path_test/min/collected_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "$output_path_test/min/correct_instances.txt"

[console]::beep(500,300)
[console]::beep(750,750)

popd