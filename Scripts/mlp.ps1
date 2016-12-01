pushd "C:\Program Files\Weka-3-8\"
Get-Variable -Exclude PWD,*Preference | Remove-Variable -EA 0

# Defines names of training/test files and input/output paths,
$train = "optraining", "optraining + 900", "optraining + 1900"
$test = "optesting", "optesting - 900", "optesting - 1900"

$names = "first", "900", "1900"

$input_path = "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\arff\${train}.arff"
$test_path = "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\arff\${test}.arff"


$output_path = "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Neural network\${name}"
$output_path_test = "C:\Users\Helmi\Google Drive\Data Mining\Coursework 3\Neural network\${name}"

# Function that iterates though MLP parameters and then performs cross validation tests
function MultilayerPerceptronCV(${train_file_path}, ${o}){
    Write-Host "Cross Validation: Multilayer Perceptron"

    New-Item ${o} -type directory -force >$null
    New-Item "${o}\cv" -type directory -force >$null
    New-Item "${o}\cv\learning rate" -type directory -force >$null
    New-Item "${o}\cv\momentum rate" -type directory -force >$null
    New-Item "${o}\cv\epochs" -type directory -force >$null
    New-Item "${o}\cv\validation threshold" -type directory -force >$null
    New-Item "${o}\cv\hidden layers" -type directory -force >$null


    New-Item "${o}\test set" -type directory -force >$null

    $out_cv = "${o}\cv"
    $out_test = "${o}\test set"

    $hidden_layers = "i", "o", "t"

    # Benchmarking
    Write-Host "Cross Validation: Benchmark"
    java -cp weka.jar weka.classifiers.functions.MultilayerPerceptron -t "${train_file_path}" -x 10 -L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E 20 -H a | Out-File ${out_cv}/benchmark.txt -Encoding ASCII

    # Varying learning rate parameter
    Write-Host "Cross Validation: Varying learning rate..."
    For(${i} = 0; ${i} -le 1; ${i} = ${i} + 0.1){
        Write-Host "`nCurrent: ${i}"
        java -cp weka.jar weka.classifiers.functions.MultilayerPerceptron -t "${train_file_path}" -x 10 -L ${i} -M 0.2 -N 500 -V 0 -S 0 -E 20 -H a | Out-File "${out_cv}/learning rate/LR-${i}.txt" -Encoding ASCII
        Write-Host "Finished: ${i}"
    }

    Remove-Item "${out_cv}/learning rate/collected_LR_output.txt"

    For(${i} = 0; ${i} -le 1; ${i} = ${i} + 0.1){
        Write-Host "Cross Validation: Extracting learning rate ${i}..."
        $result = Select-String -Path "${out_cv}/learning rate/LR-${i}.txt" -Pattern "=== Stratified cross-validation ===" -Context 0,3
        Add-Content "${out_cv}/learning rate/collected_LR_output.txt" "`n${result}"
    }

    $regex = "Correctly Classified Instances(.*)"
    Select-String -Path "${out_cv}/learning rate/collected_LR_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${out_cv}/learning rate/correct_instances_LR.txt"

    # Varying momentum rate parameter
    Write-Host "Cross Validation: Varying momentum rate..."
    For(${i} = 0; ${i} -le 1; ${i} = ${i} + 0.1){
        Write-Host "`nCurrent: ${i}"
        java -cp weka.jar weka.classifiers.functions.MultilayerPerceptron -t "${train_file_path}" -x 10 -L 0.3 -M ${i} -N 500 -V 0 -S 0 -E 20 -H a | Out-File "${out_cv}/momentum rate/MR-${i}.txt" -Encoding ASCII
        Write-Host "Finished: ${i}"
    }

    Remove-Item "${out_cv}/momentum rate/collected_MR_output.txt"

    For(${i} = 0; ${i} -le 1; ${i} = ${i} + 0.1){
        Write-Host "Cross Validation: Extracting momentum rate ${i}..."
        $result = Select-String -Path "${out_cv}/momentum rate/MR-${i}.txt" -Pattern "=== Stratified cross-validation ===" -Context 0,3
        Add-Content "${out_cv}/momentum rate/collected_MR_output.txt" "`n${result}"
    }

    $regex = "Correctly Classified Instances(.*)"
    Select-String -Path "${out_cv}/momentum rate/collected_MR_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${out_cv}/momentum rate/correct_instances_MR.txt"

    # Varying epochs
    Write-Host "Cross Validation: Varying epochs..."
    For(${i} = 0; ${i} -le 1000; ${i} = ${i} + 100){
        Write-Host "`nCurrent: ${i}"
        java -cp weka.jar weka.classifiers.functions.MultilayerPerceptron -t "${train_file_path}" -x 10 -L 0.3 -M 0.2 -N ${i} -V 0 -S 0 -E 20 -H a | Out-File "${out_cv}/epochs/EP-${i}.txt" -Encoding ASCII
        Write-Host "Finished: ${i}"
    }
    
    Remove-Item "${out_cv}/epochs/collected_EP_output.txt"

    For(${i} = 0; ${i} -le 1000; ${i} = ${i} + 100){
        Write-Host "Cross Validation: Extracting epochs ${i}..."
        $result = Select-String -Path "${out_cv}/epochs/EP-${i}.txt" -Pattern "=== Stratified cross-validation ===" -Context 0,3
        Add-Content "${out_cv}/epochs/collected_EP_output.txt" "`n${result}"
    }

    $regex = "Correctly Classified Instances(.*)"
    Select-String -Path "${out_cv}/epochs/collected_EP_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${out_cv}/epochs/correct_instances_EP.txt"

    # Varying validation threshold
    Write-Host "Cross Validation: Varying validation threshold..."
    For(${i} = 0; ${i} -le 100; ${i} = ${i} + 10){
        Write-Host "`nCurrent: ${i}"
        java -cp weka.jar weka.classifiers.functions.MultilayerPerceptron -t "${train_file_path}" -x 10 -L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E ${i} -H a | Out-File "${out_cv}/validation threshold/VT-${i}.txt" -Encoding ASCII
        Write-Host "Finished: ${i}"
    }
    
    Remove-Item "${out_cv}/validation threshold/collected_VT_output.txt"

    For(${i} = 0; ${i} -le 100; ${i} = ${i} + 10){
        Write-Host "Cross Validation: Extracting validation threshold ${i}..."
        $result = Select-String -Path "${out_cv}/validation threshold/VT-${i}.txt" -Pattern "=== Stratified cross-validation ===" -Context 0,3
        Add-Content "${out_cv}/validation threshold/collected_VT_output.txt" "`n${result}"
    }

    $regex = "Correctly Classified Instances(.*)"
    Select-String -Path "${out_cv}/validation threshold/collected_VT_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${out_cv}/validation threshold/correct_instances_VT.txt"

    # # Varying hidden layers
    Write-Host "Cross Validation: Varying hidden layers..."
    For(${i} = 0; ${i} -lt 3; ${i}++){
        Write-Host "`nCurrent: "${hidden_layers}[${i}]
        java -cp weka.jar weka.classifiers.functions.MultilayerPerceptron -t "${train_file_path}" -x 10 -L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E 20 -H ${hidden_layers}[${i}] | Out-File "${out_cv}/hidden layers/HL-${i}.txt" -Encoding ASCII
        Write-Host "Finished: "${hidden_layers}[${i}]
    }

    Remove-Item "${out_cv}/hidden layers/collected_HL_output.txt"

    For(${i} = 0; ${i} -lt 3; ${i}++){
        Write-Host "Cross Validation: Extracting hidden layers ${i}..."
        $result = Select-String -Path "${out_cv}/hidden layers/HL-${i}.txt" -Pattern "=== Stratified cross-validation ===" -Context 0,3
        Add-Content "${out_cv}/hidden layers/collected_HL_output.txt" "`n${result}"
    }

    $regex = "Correctly Classified Instances(.*)"
    Select-String -Path "${out_cv}/hidden layers/collected_HL_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${out_cv}/hidden layers/correct_instances_HL.txt"

    Write-Host "Finished cross validation"
}

# Function that iterates through MLP parameters and then performs tests on the corresponding test sets
function MultilayerPerceptronTest(${train_file_path}, ${o}, ${test_file_path}){
    Write-Host "Test Set: Multilayer Perceptron"

    New-Item ${o} -type directory -force >$null
    New-Item "${o}\test set" -type directory -force >$null
    New-Item "${o}\test set\learning rate" -type directory -force >$null
    New-Item "${o}\test set\momentum rate" -type directory -force >$null
    New-Item "${o}\test set\epochs" -type directory -force >$null
    New-Item "${o}\test set\validation threshold" -type directory -force >$null
    New-Item "${o}\test set\hidden layers" -type directory -force >$null

    $out_test = "${o}\test set"

    $hidden_layers = "i", "o", "t"

    # # Benchmarking
    Write-Host "Test set: Benchmark"
    java -cp weka.jar weka.classifiers.functions.MultilayerPerceptron -t "${train_file_path}" -T ${test_file_path} -L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E 20 -H a | Out-File ${out_test}/benchmark.txt -Encoding ASCII

    # # Varying learning rate parameter
    Write-Host "Test set: Varying learning rate..."
    For(${i} = 0; ${i} -le 1; ${i} = ${i} + 0.1){
        Write-Host "`nCurrent: ${i}"
        java -cp weka.jar weka.classifiers.functions.MultilayerPerceptron -t "${train_file_path}" -T ${test_file_path} -L ${i} -M 0.2 -N 500 -V 0 -S 0 -E 20 -H a | Out-File "${out_test}/learning rate/LR-${i}.txt" -Encoding ASCII
        Write-Host "Finished: ${i}"
    }
    
    Remove-Item "${out_test}/learning rate/collected_LR_output.txt"

    For(${i} = 0; ${i} -le 1; ${i} = ${i} + 0.1){
        Write-Host "Test set: Extracting learning rate ${i}..."
        $result = Select-String -Path "${out_test}/learning rate/LR-${i}.txt" -Pattern "=== Error on test data ===" -Context 0,3
        Add-Content "${out_test}/learning rate/collected_LR_output.txt" "`n${result}"
    }

    $regex = "Correctly Classified Instances(.*)"
    Select-String -Path "${out_test}/learning rate/collected_LR_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${out_test}/learning rate/correct_instances_LR.txt"

    # Varying momentum rate parameter
    Write-Host "Test set: Varying momentum rate..."
    For(${i} = 0; ${i} -le 1; ${i} = ${i} + 0.1){
        Write-Host "`nCurrent: ${i}"
        java -cp weka.jar weka.classifiers.functions.MultilayerPerceptron -t "${train_file_path}" -T ${test_file_path} -L 0.3 -M ${i} -N 500 -V 0 -S 0 -E 20 -H a | Out-File "${out_test}/momentum rate/MR-${i}.txt" -Encoding ASCII
        Write-Host "Finished: ${i}"
    }
    
    Remove-Item "${out_test}/momentum rate/collected_MR_output.txt"

    For(${i} = 0; ${i} -le 1; ${i} = ${i} + 0.1){
        Write-Host "Test set: Extracting momentum rate ${i}..."
        $result = Select-String -Path "${out_test}/momentum rate/MR-${i}.txt" -Pattern "=== Error on test data ===" -Context 0,3
        Add-Content "${out_test}/momentum rate/collected_MR_output.txt" "`n${result}"
    }

    $regex = "Correctly Classified Instances(.*)"
    Select-String -Path "${out_test}/momentum rate/collected_MR_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${out_test}/momentum rate/correct_instances_MR.txt"

    # # Varying epochs
    Write-Host "Test set: Varying epochs..."
    For(${i} = 0; ${i} -le 1000; ${i} = ${i} + 100){
        Write-Host "`nCurrent: ${i}"
        java -cp weka.jar weka.classifiers.functions.MultilayerPerceptron -t "${train_file_path}" -T ${test_file_path} -L 0.3 -M 0.2 -N ${i} -V 0 -S 0 -E 20 -H a | Out-File "${out_test}/epochs/EP-${i}.txt" -Encoding ASCII
        Write-Host "Finished: ${i}"
    }
    
    Remove-Item "${out_test}/epochs/collected_EP_output.txt"

    For(${i} = 0; ${i} -le 1000; ${i} = ${i} + 100){
        Write-Host "Test set: Extracting epochs ${i}..."
        $result = Select-String -Path "${out_test}/epochs/EP-${i}.txt" -Pattern "=== Error on test data ===" -Context 0,3
        Add-Content "${out_test}/epochs/collected_EP_output.txt" "`n${result}"
    }

    $regex = "Correctly Classified Instances(.*)"
    Select-String -Path "${out_test}/epochs/collected_EP_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${out_test}/epochs/correct_instances_EP.txt"

    # Varying validation threshold
    Write-Host "Test set: Varying validation threshold..."
    For(${i} = 0; ${i} -le 100; ${i} = ${i} + 10){
        Write-Host "`nCurrent: ${i}"
        java -cp weka.jar weka.classifiers.functions.MultilayerPerceptron -t "${train_file_path}" -T ${test_file_path} -L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E ${i} -H a | Out-File "${out_test}/validation threshold/VT-${i}.txt" -Encoding ASCII
        Write-Host "Finished: ${i}"
    }

    Remove-Item "${out_test}/validation threshold/collected_VT_output.txt"

    For(${i} = 0; ${i} -le 100; ${i} = ${i} + 10){
        Write-Host "Test set: Extracting validation threshold ${i}..."
        $result = Select-String -Path "${out_test}/validation threshold/VT-${i}.txt" -Pattern "=== Error on test data ===" -Context 0,3
        Add-Content "${out_test}/validation threshold/collected_VT_output.txt" "`n${result}"
    }

    $regex = "Correctly Classified Instances(.*)"
    Select-String -Path "${out_test}/validation threshold/collected_VT_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${out_test}/validation threshold/correct_instances_VT.txt"

    # # Varying hidden layers
    Write-Host "Test set: Varying hidden layers..."
    For(${i} = 0; ${i} -lt 3; ${i}++){
        Write-Host "`nCurrent: "${hidden_layers}[${i}]
        java -cp weka.jar weka.classifiers.functions.MultilayerPerceptron -t "${train_file_path}" -T ${test_file_path} -L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E 20 -H ${hidden_layers}[${i}] | Out-File "${out_test}/hidden layers/HL-${i}.txt" -Encoding ASCII
        Write-Host "Finished: "${hidden_layers}[${i}]
    }
    
    Remove-Item "${out_test}/hidden layers/collected_HL_output.txt"

    For(${i} = 0; ${i} -lt 3; ${i}++){
        Write-Host "Test set: Extracting hidden layers ${i}..."
        $result = Select-String -Path "${out_test}/hidden layers/HL-${i}.txt" -Pattern "=== Error on test data ===" -Context 0,3
        Add-Content "${out_test}/hidden layers/collected_HL_output.txt" "`n${result}"
    }

    $regex = "Correctly Classified Instances(.*)"
    Select-String -Path "${out_test}/hidden layers/collected_HL_output.txt" -Pattern "$regex" -CaseSensitive | % { $_.Matches } | % { $_.Value } > "${out_test}/hidden layers/correct_instances_HL.txt"

    Write-Host "Finished test set"
}

# Performs CV and test set experiments on every set of .arff file pairs
For(${i} = 0; ${i} -lt 3; ${i}++){
    $input_path = "C:\Users\helmi\Google Drive\Data Mining\Coursework 3\arff\"+${train}[${i}]+".arff"
    $test_path = "C:\Users\helmi\Google Drive\Data Mining\Coursework 3\arff\"+${test}[${i}]+".arff"
    $output_path = "C:\Users\helmi\Google Drive\Data Mining\Coursework 3\Neural network\"+${names}[${i}]
    Write-Host "MLP CV "${names}[${i}]
    MultilayerPerceptronCV -train_file_path ${input_path} -o ${output_path}
    Write-Host "MLP Test set "${names}[${i}]
    MultilayerPerceptronTest -train_file_path ${input_path} -o ${output_path} -test_file_path ${test_path}
}

Write-Host "Done"
popd