#' @title An experimental and unofficial R package for interacting with
#' openai-gpt
#'
#' @description
#' This R package provides an interface for interacting with openai-gpt.
#' It allows users to send messages to openai-gpt and receive responses.
#'
#' @details
#' This package provides a simple interface for interacting with openai.
#' gptchatteR is an R package that provides a simple interface for
#' interacting with the openai GPT-3 language processing model.
#' With gptchatteR, users can easily send messages to GPT-3 and receive
#' human-like responses in return. gptchatteR is easy to use and requires
#' no prior knowledge of GPT-3 or natural language processing. Simply 
#' install the package, authenticate with your openAI API key, and start
#' sending messages to GPT-3. The package also includes functions for
#' processing and displaying the generated responses.
#'
#' @return A response from openai-gpt.
#'
#' @author Isin Altinkaya
#' @examples
#' library(gptchatteR)
#'
#' # Create a chatter using your OpenAI API key
#' chatter.create(openai_secret_key = "sk-qGTnjsCI8mZkCtvXVe6S")
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
#' cplot <- chatter.plot("use ggplot to plot a scatterplot where x axis is
#' A and y axis is B", run = FALSE)
#'
#'
#' # Print the plot (if you are lucky and it runs properly)
#' cplot$plot
#'
#'
#'
# Load necessary packages
library(openai)


chatter.create <- function(input,
                           openai_secret_key = NULL,
                           model = "text-davinci-003",
                           temperature = 0.5,
                           max_tokens = 100,
                           ...) {
  if (is.null(openai_secret_key)) {
    stop(paste0(
      "\n\n[ERROR]:",
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
      "\n\t "
    ))
  }

  Sys.setenv(openai_secret_key = openai_secret_key)

  cat("\n-> Chatter is created.\n\n")

  chatter <<- structure(
    list(
      openai_secret_key = openai_secret_key,
      temperature = temperature,
      model = model,
      max_tokens = max_tokens,
      input = "",

      # fed by how many tokens in previous chat
      fed = 0
    ),
    class = "chatter"
  )

  chatter.feed <<- function(new_input) {
    chatter$input <<- paste0(chatter$input, "\n", new_input)
    chatter$fed <<- chatter$fed + 1
  }

  chatter.chat <<- function(input, echo = FALSE, return_response = FALSE, feed = FALSE, ...) {
    # if we should feed and chat at the same time
    if (feed) {
      chatter.feed(input)
      response <- openai::create_completion(
        prompt = chatter$input,
        model = model,
        temperature = temperature,
        max_tokens = max_tokens,
        echo = echo, ...
      )
      if (return_response) {
        return(response)
      } else {
        cat(response$choices[[1]]$text)
      }

      # else do not remember my current input
    } else {
      new_input <- paste0(chatter$input, "\n", input, "\n")
      response <- openai::create_completion(
        prompt = new_input,
        model = model,
        temperature = temperature,
        max_tokens = max_tokens,
        echo = echo, ...
      )
      if (return_response) {
        return(response)
      } else {
        cat(response$choices[[1]]$text)
      }
    }
  }

  chatter.plot <<- function(input, echo = FALSE, feed = FALSE, run = FALSE, ...) {
    input <- paste0("Use R for plotting. Only include the code in your replies.\n", input, "\n")
    # if we should feed and plot at the same time
    if (feed) {
      chatter.feed(input)
      response <- openai::create_completion(
        prompt = chatter$input,
        model = model,
        temperature = temperature,
        max_tokens = max_tokens,
        echo = echo, ...
      )
      if (run) {
        eval(parse(text = response$choices[[1]]$text))
      } else {
        plot <- eval(parse(text = response$choices[[1]]$text))
        structure(list(command = str2lang(response$choices[[1]]$text), plot = plot), class = "chatterplot")
      }

      # else do not remember my current input
    } else {
      new_input <- paste0(chatter$input, "\n", input, "\n")
      response <- openai::create_completion(
        prompt = new_input,
        model = model,
        temperature = temperature,
        max_tokens = max_tokens,
        echo = echo, ...
      )
      if (run) {
        eval(parse(text = response$choices[[1]]$text))
      } else {
        plot <- eval(parse(text = response$choices[[1]]$text))
        structure(list(command = str2lang(response$choices[[1]]$text), plot = plot), class = "chatterplot")
      }
    }
  }
}
