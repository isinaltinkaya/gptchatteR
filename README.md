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

And that's it! The gptchatteR package should now be installed and ready to use. You can authenticate with your openai API key using the gptchatteR_auth function, create a chatter with chatter.create function, and start sending messages to GPT-3 using the gptchatteR_schat function. For more information and examples, see the gptchatteR package documentation and tutorials.