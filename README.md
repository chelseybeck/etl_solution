# Data Engineer Homework

# Objective
The goal for this assignment is to design a simple ETL process that converts a sample of raw timeseries data into a collection of useful datasets and statistics relevant for work we do at Machina Labs. You can use whatever tools you like but make sure to include instructions in your submission for how your submission should be used and what dependencies it has.


# ETL Example
## 1. Context
At Machina Labs we use a pair of robotic arms to form sheet metal into custom geometries designed in CAD software. This is done by defining a parametric path and slowly pushing the metal sheet into the desired shape one layer at a time. A demo video is given in this repo under `demo_video.mp4`

While the robots are running we record large quantities of data in a time-series format tracking the position of the robot arms and the amount of force the arms experience using a sensor called a "load cell". An example of this data is given in the file `data/sample.csv` and is shown below:

```
|-------|--------------------------|---------------------|-------|----------|----------------------|-------------|
|       | time                     | value               | field | robot_id | run_uuid             | sensor_type |
|-------|--------------------------|---------------------|-------|----------|----------------------|-------------|
|     0 | 2022-11-23T20:40:00.444Z |            826.1516 | x     |        1 |  8910095844186657261 | encoder     |
|-------|--------------------------|---------------------|-------|----------|----------------------|-------------|
|     1 | 2022-11-23T20:40:02.111Z |            882.4617 | x     |        1 |  8910095844186657261 | encoder     |
|-------|--------------------------|---------------------|-------|----------|----------------------|-------------|
|     2 | 2022-11-23T20:40:03.778Z |            846.7317 | x     |        1 |  8910095844186657261 | encoder     |
|-------|--------------------------|---------------------|-------|----------|----------------------|-------------|

|-------|--------------------------|---------------------|-------|----------|----------------------|-------------|
|  8664 | 2022-11-23T20:40:00.444Z |  -1132.949052734375 | fx    |        1 |  7582293080991470061 | load_cell   |
|-------|--------------------------|---------------------|-------|----------|----------------------|-------------|
|  8665 | 2022-11-23T20:40:02.111Z |  -906.7292041015623 | fx    |        1 |  7582293080991470061 | load_cell   |
|-------|--------------------------|---------------------|-------|----------|----------------------|-------------|
|  8666 | 2022-11-23T20:40:03.778Z | -307.31151000976564 | fx    |        1 |  7582293080991470061 | load_cell   |
|-------|--------------------------|---------------------|-------|----------|----------------------|-------------|
```
Each entry (row) in the sample dataset gives the following features:
- `time`: The time the measurement was taken.
- `value`: The measured value corresponding to the sensor taking the reading.
- `field`: The field for the measured value. For encoders this is usually the (x,y,z) coordinate. For the `load_cell` (i.e. force measuring device) this is generally the (fx,fy,fz) coordinate.
- `robot_id`: The ID number for the robot being used (i.e. there are 2 robots so the `robot_id` is either `1` or `2`).
- `run_uuid`: A random ID number assigned to the part being formed.
- `sensor_type`: The type of sensor reporting data (e.g. encoder = robot position / load_cell = force measurements)


## 2. Instructions
Design an ETL pipeline for processing the timeseries data given in `data/sample.csv`. Your pipeline should perform the following steps:

1. Preprocess and Clean
2. Convert timeseries to features by `robot_id`
3. Include Engineered/Calculated Features
4. Calculate Runtime Statistics
5. Store and Provide Access Tools

All of these results should be saved in a format that is easy for others to access. It's up to you how you want to store things. You can use simple CSV files, a SQL database, etc. Regardless what you choose, the structure should be simple enough that we could read your results in a meaningful way.

### 2.1 Preprocess and Clean

Your first task in the ETL pipeline should be to extract/read data from `sample.csv` and pre-process/clean the data (e.g. handling NaN values, expected values, outliers). You should also consider methods for enforcing datatypes so that your pipeline doesn't break. Use your best judgement given what you understand about the type of data given what cleansing steps make sense.
### 2.2 Convert timeseries to features by `robot_id`
#### Convert to features
Timeseries is a convenient format for storing data but it's often not the most useful for interacting with, making plots, training ML models, etc. With your newly processed data, convert the timeseries data into a format that has the encoder values (x,y,z) and forces (fx,fy,fz) for each of the two robots (1,2) as individual columns. So rather than each row showing a time, sensor_type, robot_id, etc the data should show encoders (`x_1`, `y_1`, `z_1`, `x_2`, `y_2`, `z_2`) and forces (`fx_1`, `fy_1`, `fz_1`, `fx_2`, `fy_2`, `fz_2`) for every timestamp. 

In the end, the header for your data should look like the following:

```
|--------------------------|-------------|-------------|-------------|--------------|--------------|-------------|---------|----------|---------|---------|---------|-----|
| time                     | fx_1        | fx_2        | fy_1        | fy_2         | fz_1         | fz_2        | x_1     | x_2      | y_1     | y_2     | z_1     | z_2 |
|--------------------------|-------------|-------------|-------------|--------------|--------------|-------------|---------|----------|---------|---------|---------|-----|
```

#### Match timestamps with measurements
If you manage to convert the timeseries data to individual features, you'll notice many gaps in the data (like in the table shown below). This is because our robots report data independently and the load cells report force data independently from the robot encoders. This means that every combination of robot and sensor has its own timestamp (4 combinations). However, we would like to be able to compare each of these features corresponding to a single timestamp. So you should transform the data to guarantee that any timestamp we access has a value for each column. 

It's up to you how you want to do this. You can match timestamps between features, interpolate values between timestamps or any other method you deem reasonable. Regardless which strategy you choose, explain why you chose it and what benefits or trade-offs it involves.

This data should also be saved in a way that these tables can be accessed by reference to the `run_uuid`. The table below is an example of data for `run_uuid = 6176976534744076781`. 

```
|--------------------------|-------------|-------------|-------------|--------------|--------------|-------------|---------|----------|---------|---------|---------|-----|
| time                     | fx_1        | fx_2        | fy_1        | fy_2         | fz_1         | fz_2        | x_1     | x_2      | y_1     | y_2     | z_1     | z_2 |
|--------------------------|-------------|-------------|-------------|--------------|--------------|-------------|---------|----------|---------|---------|---------|-----|
| 2022-11-23T20:40:00.007Z | 176.0963814 |             | 174.2686233 |              | -258.1794165 |             |         |          |         |         |         |     |
|--------------------------|-------------|-------------|-------------|--------------|--------------|-------------|---------|----------|---------|---------|---------|-----|
| 2022-11-23T20:40:00.008Z |             |             |             |              |              |             |         | 1438.412 |         | 939.383 |         |     |
|--------------------------|-------------|-------------|-------------|--------------|--------------|-------------|---------|----------|---------|---------|---------|-----|
| 2022-11-23T20:40:00.011Z |             |             |             |              |              |             | 1440.79 |          | 936.925 |         | -222.29 |     |
|--------------------------|-------------|-------------|-------------|--------------|--------------|-------------|---------|----------|---------|---------|---------|-----|
| 2022-11-23T20:40:00.017Z | 178.4532845 |             |  172.338417 |              | -259.4669531 |             |         |          |         |         |         |     |
|--------------------------|-------------|-------------|-------------|--------------|--------------|-------------|---------|----------|---------|---------|---------|-----|
| 2022-11-23T20:40:00.01Z  |             | 50.37302734 |             | -416.0604053 |              | 80.69138062 |         |          |         |         |         |     |
|--------------------------|-------------|-------------|-------------|--------------|--------------|-------------|---------|----------|---------|---------|---------|-----|
| 2022-11-23T20:40:00.023Z |             |             |             |              |              |             | 1440.79 |          | 936.925 |         | -222.29 |     |
|--------------------------|-------------|-------------|-------------|--------------|--------------|-------------|---------|----------|---------|---------|---------|-----|
```

### 2.3 Include Engineered/Calculated Features

Recorded values are great but often times we want to calculate some other useful information. In the previous step you created a more convenient format for our encoder and force data. Take this information and generate some engineered features. You should include the follwing features:
- 3 Velocity values (vx_1, vy_1, vz_1, vx_2, vy_2, vz_2)
- 3 Acceleration values (ax_1, ay_1, az_1, ax_2, ay_2, az_2)
- Total Velocity (v1, v2)
- Total Acceleration (a1, a2)
- Total Force (f1, f2)

You can add in any other features you think would be useful or informative from the original data. 

### 2.4 Calculate Runtime Statistics

Produce a dataset that provides useful statistics about the different `run_uuid` information. Your statistics data should include the following:
- `run_uuid`
- run start time
- run stop time
- total runtime
- total distance traveled 
- minimum speed
- maximum speed
- average speed
- minimum acceleration
- maximum acceleration
- average acceleration 
- minimum total force
- maximum total force
- average total force 

### 2.5 Store and Provide Access Tools

In the end, all of this information should be saved somewhere that is easy for other people to access. You can decide how you prefer to store this information. Maybe you prefer a SQL database. Maybe you prefer a tabular format. Choose the approach that you think makes the most sense for this specific setup. You can also choose how you want this information distributed. Do you think it should all be saved in one location? Should it be saved across multiple separate data stores? 

## Tips & Advice

Try to follow ETL best practices for your example code. Good habits that we like to see might include:
- Making your tasks modular and easy to iterate on or modify. Adding a new task into the pipeline shouldn't break the rest of the ETL flow.
- Enforce datatypes and include exception handling and data cleaning measures for dealing with errors.
- Consider a design for your workflow that would make it easy to modify or update data as new features get added. If you put all of the data in one location, how easy would it be to udpate or modify. If you spread your data across multiple locations, how would updates or modifications propagate to all those locations? 
- Consider processing speed and use parallel processing for independent tasks when possible. Which parts of your pipeline can be parallelized? Which have to be done sequentially?
- Save data in formats that are easily extensible and convneint to query.

## Conclusion 

There is a lot of information contained in this Readme. Most of the suggestions are based on experiences we've had designing our own ETL process. However we are interested in seeing how you approach these problems. So feel free to deviate from these suggestions where you think it's appropriate. Also, we strongly encourage you to include comments and descriptions of your thought process in your final solution. If you would like to submit a readme or document with notes and explanations for your ETL we will gladly take that into account when reviewing your code.

# Submission
In order to submit the assignment, do the following:

1. Navigate to GitHub's project import page: [https://github.com/new/import](https://github.com/new/import)

2. In the box titled "Your old repository's clone URL", paste the homework repository's link: [https://github.com/Machina-Labs/data_engineer_hw](https://github.com/Machina-Labs/data_engineer_hw)

3. In the box titled "Repository Name", add a name for your local homework (ex. `data_engineer_soln`)

4. Set privacy level to "Public", then click "Begin Import" button at bottom of the page.

5. Develop your homework solution in the cloned repository and push it to Github when you're done. Extra points for good Git hygiene.

6. Send us the link to your repository.