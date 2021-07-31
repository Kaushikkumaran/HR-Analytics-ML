# HR Analytics ML

# HR Analytics Problem Statement and Description
- A Data Science firm rolled out a technical training program.
- Wants to identify applicants (targets) who would join the firm after training
- Focussed training (better quality, costlier) to be provided to the targets

Objective - Calculate propensity of an applicant to join the firm

# Data
### Data Challenges
Missing values: ~ 32% of Company Type are blanks
Incorrect values: ‘10-49 seats’ in Company Size is being captured as date type instead of string

### Pre-processing
Missing values are imputed as 'Missing' for model to learn
Incorrect values are treated in excel before loading data
Grouping City data – Grouped less common city ids into “others” bucket based on their proportion in data (<2.5%)  

# Insights

### 80% of targeted individuals come from 15% of total cities
![image](https://user-images.githubusercontent.com/20616274/127086767-900729c4-5aa0-4bd9-b135-eb452fcaee24.png)

### % Targeted individuals are not in the same order as % Applicants from each city
![image](https://user-images.githubusercontent.com/20616274/127086840-fa0aeec1-8cf6-43da-a4cc-d9c341b1330b.png)

### For targets with lower experience, no relevant experience is acceptable, for targets with high experience, relevant experience is preferred 
![image](https://user-images.githubusercontent.com/20616274/127086888-d91fa613-537a-441a-89ca-9c0356a41a54.png)

# Modeling Techniques
![image](https://user-images.githubusercontent.com/20616274/127086939-5eae7d16-7a37-4ba4-964d-f85688dab998.png)

### Variable Importance and Confusion Matrix
![image](https://user-images.githubusercontent.com/20616274/127086998-d6d08628-1d22-427d-8ed2-436b63172d4c.png)
![image](https://user-images.githubusercontent.com/20616274/127087010-38d195c4-a09e-4e71-a2d6-7bddf193688f.png)

Confusion Matrix:
![image](https://user-images.githubusercontent.com/20616274/127087078-25f7d10e-829f-4286-920f-2f426b58ba40.png)

# Business Impact
![image](https://user-images.githubusercontent.com/20616274/127087141-d1b8869d-9705-4279-874e-210d80918c2e.png)


# Detailed EDA
## Univariate Analysis

### Target Dependent Variable
![image](https://user-images.githubusercontent.com/20616274/126241881-dca924cc-78ff-4011-8c57-fda68171efd2.png)

### Relevant Experience
![image](https://user-images.githubusercontent.com/20616274/126241916-ff752360-0309-4091-8c06-324b732491ae.png)

### Enrolled University
![image](https://user-images.githubusercontent.com/20616274/126241933-0b558cc1-4f57-493e-a7ea-ce5d1736bb6b.png)

### Education Level
![image](https://user-images.githubusercontent.com/20616274/126241953-d2afada4-4579-43d5-8f69-be5ae1ca1e52.png)

### Gender
![image](https://user-images.githubusercontent.com/20616274/126241973-4f46f888-f2f6-47ef-9c8c-3c446d3db130.png)

### Company Type
![image](https://user-images.githubusercontent.com/20616274/126241997-5548f1b5-c399-4986-bdf4-f81e9cb1a74a.png)

### Major Discipline
![image](https://user-images.githubusercontent.com/20616274/126242032-e4e3ebbf-b7de-4a96-b6e3-b98e6063f80b.png)

### Last New Job
![image](https://user-images.githubusercontent.com/20616274/126242058-9deaac78-c63a-4e9b-9861-e90724a4c8ba.png)

## Bivariate Analysis
### Relevant Experience vs Target
![image](https://user-images.githubusercontent.com/20616274/126242105-a89efc7b-d394-4bdc-beef-aadfee233516.png)

### Enrolled University vs Target
![image](https://user-images.githubusercontent.com/20616274/126242133-fd063b50-6bb6-4fdc-8bd7-bb1d9f607edc.png)

### Correlation plot for the numeric columns
![image](https://user-images.githubusercontent.com/20616274/126242188-91ac3de9-43ee-4d14-904b-538418144928.png)






