# VSD-TCL WORKSHOP

A User Interface (UI) that will take RTL netlist & SDC constraints as an input, and will generate sythnesized netlist & pre-layout timing report as an output. It uses Yosys open-source tool for synthesis and Opentimer to generate pre-layout timing reports.

## DAY 1:

### A command that passes a .csv file from UNIX shell to TCL script.
  
#### It checks for the following conditions and responds as shown below:
- CSV file not provided
- Incorrect CSV file
- "-help" for user guidance

  
<img width="600" alt="Output" src="https://github.com/shreyas0770/TCL/assets/107952725/27480afd-9f16-4af0-a7ec-05454013a5de">



## DAY 2:
### Varible creation and processing contraints from CSV
**Tasks:**
  1. Autocreation of Variables
  2. Check if directories and files mentioned exist or not
  3. Read constraints file and covert to SDC format

#### Output:

<img width="800" alt="day_2_final_output" src="https://github.com/shreyas0770/TCL/assets/107952725/2c2e42f7-a9aa-4d7e-a7f1-9a11131fb562">


## DAY 3:
### Processing clock and input constraints
**Task:** Convert contraints.csv file into SDC format
   


**Outputs:**

SDC file for Clock:

<img width="400" alt="SDC_FILE" src="https://github.com/shreyas0770/TCL/assets/107952725/d295b9fa-67e6-4375-811f-e036e855d4b0">



FINAL SDC:

<img width="400" alt="FINAL_SDC_OUTPUT" src="https://github.com/shreyas0770/TCL/assets/107952725/07827c8f-9308-4402-bd2f-082285ae5ada">


OUTPUT:

<img width="600" alt="final_output" src="https://github.com/shreyas0770/TCL/assets/107952725/9eeafce8-92b7-442d-873b-4d1f3fd1d9c1">



## DAY 4:
### Synthesis on Yosys
#### Yosys:
Yosys is the first full-featured open source software for Verilog HDL
synthesis. It supports most of Verilog-2005 and is well tested with
real-world designs from the ASIC and FPGA world.


Synthesis on yosys for the following RTL code:

<img width="400" alt="memory_rtl" src="https://github.com/shreyas0770/TCL/assets/107952725/72c776e3-bf92-4b16-a614-8323db2a93af">



Synthesis output:

<img width="600" alt="yosys_proof" src="https://github.com/shreyas0770/TCL/assets/107952725/2967b484-b1dc-433e-a08d-03b77673f16c">


<img width="600" alt="synthesized_output" src="https://github.com/shreyas0770/TCL/assets/107952725/ba822def-2bfe-4488-b371-25900a71de18">



Netlist:

<img width="400" alt="memory_synth1" src="https://github.com/shreyas0770/TCL/assets/107952725/792838a2-4eac-47be-9c63-c5f214063f64">

<img width="285" alt="memory_synth2" src="https://github.com/shreyas0770/TCL/assets/107952725/fda31473-8d94-4aa2-9900-2212883c7414">




**Hierarchy Check**

Hierarchy file:

<img width="400" alt="heirarchy_file" src="https://github.com/shreyas0770/TCL/assets/107952725/bf69fc1a-f2ae-441c-be17-72c598329682">


When all the modules called in the top module exist:

<img width="600" alt="after_check_pass" src="https://github.com/shreyas0770/TCL/assets/107952725/a3bcdf42-ad72-4a37-9d4e-9a035c0d5e23">


Forcing an error by changing the module name:

<img width="400" alt="making_error" src="https://github.com/shreyas0770/TCL/assets/107952725/407ceb95-2639-4ed0-a1df-6a8eaa0363a0">


Error spotted, i.e Hierarchy check fail:

<img width="600" alt="final_error_day4" src="https://github.com/shreyas0770/TCL/assets/107952725/39445b17-9620-4829-bd4f-4e975785e4da">


## DAY 5:

###To run STA analysis on OpenTimer

#### OpenTimer tool:
OpenTimer is a new static timing analysis (STA) tool to help IC designers quickly verify the circuit timing. It is developed completely from the ground up using C++17 to   efficiently support parallel and incremental timing. Key features are:
  - Industry standard format (.lib, .v, .spef, .sdc) support
  - Graph- and path-based timing analysis
  - Parallel incremental timing for fast timing closure

#### Main synthesis script:

  <img width="400" alt="ys_file" src="https://github.com/shreyas0770/TCL/assets/107952725/9c8d5b0e-dc85-45fd-915c-32cd7d783b2d">

#### Running synthesis on Yosys

  <img width="600" alt="SYNTHESIS_SUCCESS" src="https://github.com/shreyas0770/TCL/assets/107952725/67f8810e-2d5b-449d-8fe7-01d6e2b36262">

#### Edit synthesis file so that it can used by OpenTimer

  Unedited synthesis file:
  
  <img width="250" alt="synth_with_star" src="https://github.com/shreyas0770/TCL/assets/107952725/ae5c0cc0-9083-4ff5-b928-b934f00ffc41">
  <img width="800" alt="synth_start" src="https://github.com/shreyas0770/TCL/assets/107952725/07f823a1-5490-413a-ac67-73ea39333cc0">

  
  Edited synthesis file:
  
  <img width="250" alt="final_synth v" src="https://github.com/shreyas0770/TCL/assets/107952725/5e21a419-f285-4218-bc0a-399897f90ceb">
  <img width="800" alt="final_synth_start" src="https://github.com/shreyas0770/TCL/assets/107952725/3c220b5e-4ab4-4603-8528-a3c0be7dc574">

  As seen from the above two images, we remove the characters "\\\" and "*" from the original synthesis file to be usable by OpenTimer.

- **Procs:**
  
    Procs, short for processes, are fundamental units of execution in Electronic Design Automation (EDA) tools. They represent specific tasks or operations performed       during the design flow of integrated circuits. Procs encapsulate algorithms, functions, or scripts that automate various design tasks, such as synthesis, placement, routing, and verification.

  1.reopenStdout

    ![image](https://github.com/shreyas0770/TCL/assets/107952725/20a72914-d79a-47fb-a929-498dbf37e5b1)

  2.read_verilog

    ![image](https://github.com/shreyas0770/TCL/assets/107952725/40b87317-70db-473b-a66c-23770a34d3d5)

  3.set_num_threads

   <img width="500" alt="STA_OUT_PROOF_1" src="https://github.com/shreyas0770/TCL/assets/107952725/be2d4ba1-d50b-4fa4-bc4b-bc5a0ae3d25b">

  4.read_lib

   <img width="500" alt="STA_OUT_PROOF_1" src="https://github.com/shreyas0770/TCL/assets/107952725/78578634-17dd-401e-8f34-f32bbc977a84">

- **STA using OpenTimer:**

  By using the procs mentioned above, we can obtain the number of threads, libraries etc as shown below
  
  <img width="600" alt="STA_OUT_PROOF_1" src="https://github.com/shreyas0770/TCL/assets/107952725/41ed8b29-c0d3-46b6-b8c9-964a20b4ff65">

- **Configuration file for OpenTimer**

  <img width="600" alt="conf_file_opentimer" src="https://github.com/shreyas0770/TCL/assets/107952725/e845f1e1-3200-44a1-8179-ebaba20d10cd">

- **Standard Parasitic Exchange Format (SPEF) file**

  <img width="600" alt="spec_file_opentimer" src="https://github.com/shreyas0770/TCL/assets/107952725/96298b58-03f2-4502-813c-2eadd14cb228">








  

                                                          









