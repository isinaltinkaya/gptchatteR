# gptchatteR
An experimental and unofficial wrapper for interacting with ChatGPT in R.


## Installation

### Prerequisites
Install the devtools package by running the following command in your R console:

```R
install.packages("devtools", "openai")
#Load the devtools package by running the following command in your R console:
library(devtools)
```

Install the gptchatteR package from the isinaltinkaya GitHub repository by running the following command in your R console:
```r
install_github("isinaltinkaya/gptchatteR")
```
Load the gptchatteR package by running the following command in your R console:
```R
library(gptchatteR)
```

And that's it! The gptchatteR package should now be installed and ready to use. 
You can authenticate with your openai API key using the `chatter.auth` function, create a chatter with `chatter.create` function, and start sending messages to GPT-3 using the `chatter.chat` function. For more information and examples, see the gptchatteR package documentation and tutorials.

```R
# Load the devtools package
library(devtools)

# Install the gptchatteR package from GitHub using the devtools package
install_github("isinaltinkaya/gptchatteR")

# Load the gptchatteR package
library(gptchatteR)

# Authenticate using your API key
chatter.auth("sk-qGTnjsCI8mZkCtvXVe6SUSEYOUROWNKEY")

# Create a new chat session 
chatter.create()
```

## Example 1

```R
# Create test data
df <- data.frame(A=seq(1,10,1),B=seq(10,19,1))

# Feed the chatter instance
chatter.feed("I have a dataframe named df. It has two columns: A and B")

# Save the chatter response object
cp <- chatter.plot("Plot a scatterplot where x axis is A, y is B")
```

## Example 2

```R
# Create a test data frame
library(tidyverse)
rt <- rnorm(1000, mean=700, sd=100) # Generate RT data
df <- tibble(RT = rt, group = rep(c("low", "high"), each=500))

# Feed the data frame information to the chat session
chatter.feed("I have a dataframe df")

# Use the chatter.plot function to create a histogram
chatter.plot("plot histogram of rt using ggplot with df")
```

### Acknowledgements: 
ChatGPT
