import React from 'react';
import { Controller, useForm } from 'react-hook-form';
import Input from "@mui/material/Input";
import { Button, MenuItem, Select, Slider, TextField } from '@mui/material';

const marks = [
  {
    value: 1,
    label: '1',
  },
  {
    value: 2,
    label: '2',
  },
  {
    value: 3,
    label: '3',
  },
  {
    value: 4,
    label: '4',
  },
  {
    value: 5,
    label: '5',
  },
];

function valuetext(value) {
  return `${value}`;
}

export default function App() {
  const { control, handleSubmit } = useForm();
  const onSubmit = async (data) => {
    console.log(data);

    const requestOptions = {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
      mode: "no-cors"
    };

    const response = await fetch(["https://nerts2023.gcardona.me/submit"], requestOptions);
    const jsonData = await response.json();

    console.log(jsonData);
    alert(jsonData.message);
  }
  
  return (
    <div style={{width: "90%", paddingLeft: "25px"}}>
      <h1>Welcome to the Feedback Form, ALPFA NERTS 2023 Guests!</h1>
      <b>NOTE: All fields on this form are optional</b>
      <br/>
      <form onSubmit={handleSubmit(onSubmit)}>
        <label style={{paddingRight: '10px'}}>What is your name?</label>
        <Controller
          name="name"
          control={control}
          render={({ field }) => <Input {...field} />}
          className="materialUIInput"
          rules={{ maxLength: 80 }}
          defaultValue=""
        ></Controller>
        <br/><br/>
        <label style={{paddingRight: '10px'}}>What is your experience level in cloud?</label>
        <Controller
          name="experience"
          control={control}
          render={({ field }) => <Select {...field}>
            <MenuItem value={"N/A"}>N/A</MenuItem>
            <MenuItem value={"New to Cloud"}>New to Cloud</MenuItem>
            <MenuItem value={"Evaluated Cloud"}>Evaluated Cloud</MenuItem>
            <MenuItem value={"Actively Use Cloud"}>Actively Use Cloud</MenuItem>
            <MenuItem value={"Actively Run/Manage Production Workloads on Cloud"}>Actively Run/Manage Production Workloads on Cloud</MenuItem>
          </Select>}
          className="materialUIInput"
          defaultValue="N/A"
        ></Controller>
        <br/><br/>
        <label>Please rate the 101 section</label>
        <Controller
          name="rating_101"
          control={control}
          render={({ field }) => <Slider {...field}
            valueLabelDisplay="auto"
            getAriaValueText={valuetext}
            step={1}
            max={5}
            min={1}
            marks={marks}  />}
          className="materialUIInput"
          defaultValue={1}
        ></Controller>
        <br/><br/>
        <label>Please rate the 102 section</label>
        <Controller
          name="rating_102"
          control={control}
          render={({ field }) => <Slider {...field}
            valueLabelDisplay="auto"
            getAriaValueText={valuetext}
            step={1}
            max={5}
            min={1}
            marks={marks}  />}
          className="materialUIInput"
          defaultValue={1}
        ></Controller>
        <br/><br/>
        <label>Please rate the 103 section</label>
        <Controller
          name="rating_103"
          control={control}
          render={({ field }) => <Slider {...field}
            valueLabelDisplay="auto"
            getAriaValueText={valuetext}
            step={1}
            max={5}
            min={1}
            marks={marks}  />}
          className="materialUIInput"
          defaultValue={1}
        ></Controller>
        <br/><br/>
        <label>Was there any part of the presentation you found memorable? If so, please share</label>
        <br/>
        <Controller
          name="memorable_notes"
          control={control}
          render={({ field }) => <TextField {...field} 
            multiline
            rows={2}
            fullWidth/>}
          className="materialUIInput"
          defaultValue=""
        ></Controller>
        <br/><br/>
        <label>Do you have any additional feedback? If so, please share</label>
        <br/>
        <Controller
          name="additional_notes"
          control={control}
          render={({ field }) => <TextField {...field} 
            multiline
            rows={2}
            fullWidth/>}
          className="materialUIInput"
          defaultValue=""
        ></Controller>
        <br/><br />
        <Button variant="contained" type="submit">Submit</Button>
    </form>
    </div>
  );
}
