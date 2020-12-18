# Predict sex from brain rhythms   
Julieva Cohen, Alexandra, Antoine Settelen, Simon Weiss   
U2 Project - Modeling Technics of Big Data     

~3 weeks development      

*Disclaimer : 
here we will try to predict what science and medicine calls sex at the birth of a person. 
We would like to emphasize that this has nothing to do with nor determine in any way determine a person's gender, or non-gender.*

This group project responds to **professor Serge Nyawa instructions** written below :

Your topic should be related to Big Data Analytics with a Business/economics/finance interest and should contain :
-         Discovery: learn the business domain, assess the resources available to support the project, frame the business problem as an analytics challenge, formulate initial hypotheses to test.
-         Data preparation: explain how you did the extract, load, and transform (ELT) or extract, transform and load (ETL) steps, to get your data.
-         Model planning: explain and justify the choice of your methods, techniques. Describe how you learn about the relationships between variables, how you did the selection of key variables and the most suitable models.
-         Model building / estimation: explain your estimation strategy and results.
-         Communicate results: determine if the results of the project are a success or a failure, identify key findings, quantify the business value, and develop a narrative to convey findings to stakeholders.



This is a notebook for the Dream Company https://github.com/13w13/U2-Predict-from-brain-rhythms 
Data Challenge January 2020 with College de France https://www.college-de-france.fr/site/stephane-mallat/Challenge-2019-2020-Prediction-du-sexe-en-fonction-du-rythme-cerebral.htm and ENS https://challengedata.ens.fr/challenges/27


**The goal of this playground challenge** is to predict *sex from brain rhythms*. The Dreem headband collects physiological activity during sleep, such as brain activity (electroencephalograph), respiration and heart rate. 




The challenge we’ve chosen is a challenge proposed by a Paris neurotechnology startup called Dream.It is indeed a question of measuring brain activity, thanks to sensors placed on the skull of a person and measuring the electrical activity of neurons around these captures. Dream company choose this project because: “We have excellent skills to extract sex from visual assessment of human faces, but assessing sex from human brain rhythms seems impossible.” 

When a person is asleep, and depending on his state of sleep, we will observe different patterns that will allow us to better characterize what happens in the brain during the night.

“For several decades, traditional machine learning techniques have been frequently applied to brain imaging data, including electroencephalography (EEG), with applications ranging from characterization of the EEG background pattern or quantification of focal or global ischaemia to detection of epileptiform discharges and diagnostics in depression. Common to most of these techniques is the requirement for prior assumptions to guide extraction of particular features to be used for classification. Examples include spectral features or correlations between EEG signals from different brain regions. A limitation of these approaches is that unknown and potentially relevant features may not be included. Deep nets do not need prior extraction of such hand-made features, can learn from raw data, and have potential to detect subtle differences in otherwise similar patterns.” https://www.nature.com/articles/s41598-018-21495-7





The data used was collected on 946 individuals during the night, with eyes closed and in a relaxed state. We put 7 sensors on their skull. These sensors recovered during the night 40 segments of 2 seconds for each individual.
![Lax Airport](https://aecom.com/ie/wp-content/uploads/2013/12/AECOM2.18.14-160_ES.tif-797x531.jpg)

![Resutls from data challenge provider](https://drive.google.com/file/d/1xJSdfClttPQS3GFheoHWqfwqo9Wi5DMK/view?usp=sharing)


**In this notebook**, 
We will first clean the dataset, the data format was on HDF5 so we have to do some researches to convert it into a dataset more easily manageable on R. Then, we study and visualize the original data, and examine potential outliers. We need after that to apply a Fourier transformation to convert the frequencies into Hertz. Regarding the model, we implement a Random Forest and a neural network.






We hope that this notebook will have good results to the challenge and  fully answer Serge Nyawa's requirements.


As always, any feedback, questions, or constructive criticism are much appreciated.






The steps of our project are :
1. Presentation of the project
2. Data extraction from h5 to csv
3. Exploratory data analysis & Pre-processing
4. Modeling
5. Predict and export results

Set-up used during the project : 

1. Notebook Ipynb with R kernel version 3.6
2. Microsoft Azure Machine Learning
3. Calculation instance with optimized memory: Virtual machine size - STANDARD_D12_V2 (4 cores, 28 GB RAM, 200 GB disk)
4. Result on the ENS data challenge platform : https://challengedata.ens.fr/participants/challenges/27/
5. Github repositoty : https://github.com/13w13/U2-Predict-from-brain-rhythms


