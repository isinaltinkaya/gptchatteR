#' @title An experimental and unofficial R package for interacting with openai-gpt
#'
#' @description
#' This R package provides an interface for interacting with openai-gpt.
#' It allows users to send messages to openai-gpt and receive responses.
#'
#' @details
#' This package provides a simple interface for interacting with openai-gpt.
#' It allows users to send messages to openai-gpt and receive responses.
#' Users can specify the type of response they want (e.g. text, image)
#' and openai-gpt will generate the appropriate response.
#'
#' @return A response from openai-gpt.
#'
#' @author Your name

#' @examples
#' library(gptchatter)
#'
#' # Create a chatter using your OpenAI API key
#' chatter.create(openai_secret_key =  "sk-qGTnjsCI8mZkCtvXVe6S")
#'
#' # Start talking!
#' chatter.chat("Hi!")
#'
#' # Feed the chatter with prior information
#' chatter.feed("My name is Isin.")
#' chatter.chat("What is my name?")
#'
#'
#' # A real example (Note: The object (i.e. df) should be defined.)
#' chatter.feed("I have a dataframe named df. It has two columns: A and B")
#'
#' cplot<-chatter.plot("use ggplot to plot a scatterplot where x axis is A and y axis is B",run=FALSE)
#'
#'
#' # Print the plot (if you are lucky and it run properly)
#' cplot$plot
#'


# Load necessary packages
library(openai)
library(tidyr)


chatter.create <- function(input,
                           openai_secret_key = NULL,
                           model= "text-davinci-003",
                           temperature = 0.5,
                           max_tokens = 100,
                           ...) {

  if(is.null(openai_secret_key)){
    stop(paste0("\n\n[ERROR]:",
                "'openai_secret_key' is not defined.",
                "\n\n-> You need to provide an OpenAI secret key.\n\n",
                "Example: chatter.create(openai_secret_key=\"lbkFJuMOwtvGYKOWzYJsFNw2L\")",
                "\n\n\nTo get your OpenAI API key:",
                "\n\tStep 1: Visit the OpenAI website at https://beta.openai.com/ and click 'Sign Up'",
                "\n\tStep 2: Enter your information and click 'Create Account'",
                "\n\tStep 3: Log in to your account",
                "\n\tStep 4: On the left side of the page, click on 'API Keys'",
                "\n\tStep 5: Click 'Create new secret key'",
                "\n\tStep 6: Copy your API key and use as below:",
                "\n\t\tchatter.create(openai_secret_key=\"MY_SECRET_KEY\")",
                "\n\t "))
  }

  Sys.setenv(openai_secret_key = openai_secret_key)

  cat("\n-> Chatter is created.\n\n")

  chatter <<- structure(
    list(
      openai_secret_key = openai_secret_key,
      temperature = temperature,
      model = model,
      max_tokens = max_tokens,
      input="",

      # fed by how many tokens in previous chat
      fed=0),
    class = "chatter"
  )

  chatter.feed<<-function(new_input) {
    chatter$input<<-paste0(chatter$input,"\n",new_input)
    chatter$fed<<-chatter$fed+1
  }

  chatter.chat<<-function(input, echo=FALSE, return_response=FALSE, feed=FALSE,...) {

    # if we should feed and chat at the same time
    if(feed){
      chatter.feed(input)
      response<-create_completion(prompt = chatter$input,
                                  model=model,
                                  temperature = temperature,
                                  max_tokens = max_tokens,
                                  echo=echo,...)
      if(return_response){
        return(response)
      }else{
        cat(response$choices[[1]]$text)
      }

    #else do not remember my current input
    }else{
      new_input<-paste0(chatter$input,"\n",input,"\n")
      response<-create_completion(prompt = new_input,
                                  model=model,
                                  temperature = temperature,
                                  max_tokens = max_tokens,
                                  echo=echo,...)
      if(return_response){
        return(response)
      }else{
        cat(response$choices[[1]]$text)
      }
    }
  }

  chatter.plot<<-function(input, echo=FALSE, feed=FALSE,run=FALSE,...) {

    input<-paste0("Use R for plotting. Only include the code in your replies.\n",input,"\n")
    # if we should feed and plot at the same time
    if(feed){
      chatter.feed(input)
      response<-create_completion(prompt = chatter$input,
                                  model=model,
                                  temperature = temperature,
                                  max_tokens = max_tokens,
                                  echo=echo, ...)
      if(run){
        eval(parse(text=response$choices[[1]]$text))
      }else{
        plot<-eval(parse(text=response$choices[[1]]$text))
        structure(list(command=str2lang(response$choices[[1]]$text), plot=plot),class="chatterplot")
      }

    #else do not remember my current input
    }else{
      new_input<-paste0(chatter$input,"\n",input,"\n")
      response<-create_completion(prompt = new_input,
                                  model=model,
                                  temperature = temperature,
                                  max_tokens = max_tokens,
                                  echo=echo,...)
      if(run){
        eval(parse(text=response$choices[[1]]$text))
      }else{
        plot<-eval(parse(text=response$choices[[1]]$text))
        structure(list(command=str2lang(response$choices[[1]]$text), plot=plot),class="chatterplot")
      }
    }
  }
}

