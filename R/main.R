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
#' chatter.auth(openai_secret_key = "sk-qGTnjsCI8mZkCtvXVe6S")
#'
#' chatter.create()
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
#'

#' Authenticate chatter with an OpenAI secret key
#'
#' This function can be used to authenticate a user with an OpenAI
#' secret key. It takes the argument \code{openai_secret_key} and if it
#' i snot provided, an error message is displayed with instructions on
#' how to get an OpenAI secret key. The secret key is then stored as an
#' environment variable.
#'
#' @param openai_secret_key The OpenAI secret key for authentication
#'
#' @examples
#' chatter.auth(openai_secret_key = "lbkFJuMOwtvGYKOWzYJsFNw2L")
#'
#' @export chatter.auth
chatter.auth <- function(openai_secret_key = NULL) {
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
      "\n\t\tchatter.auth(openai_secret_key=\"MY_SECRET_KEY\")",
      "\n\t "
    ))
  }
  Sys.setenv(OPENAI_API_KEY = openai_secret_key)
}


#' Create an OpenAI chatterbot
#'
#' @param model The OpenAI model to use (default is \code{text-davinci-003})
#' @param temperature Float between 0 and 1, representing the degree of
#' randomness (default is \code{0.5})
#' @param max_tokens Maximum number of tokens to generate
#' (default is \code{100})
#' @param ... Other arguments passed to \code{\link[openai]{create_completion}}
#'
#' @return A \code{chatter} object containing the OpenAI secret key and the
#' provided parameters
#'
#' @examples
#'
#' chatter.auth(openai_secret_key = "MY_SECRET_KEY")
#'
#' @export chatter.create
#'
#' @seealso \code{\link{chatter.auth}, \link{chatter.feed}},
#' \code{\link{chatter.chat}},\code{\link{chatter.plot}}
#'
#' @importFrom openai create_completion
chatter.create <- function(model = "text-davinci-003",
                           temperature = 0.5,
                           max_tokens = 100,
                           ...) {
  if (Sys.getenv("OPENAI_API_KEY") == "" || is.na(Sys.getenv("OPENAI_API_KEY"))) {
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
      "\n\t\tchatter.auth(openai_secret_key=\"MY_SECRET_KEY\")",
      "\n\t "
    ))
  }



  chatter <<- structure(
    list(
      openai_secret_key = Sys.getenv("openai_secret_key"),
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
        engine_id = chatter$model,
        temperature = chatter$temperature,
        max_tokens = chatter$max_tokens,
        echo = echo
      )
      if (return_response) {
        return(response)
      } else {
        cat(response$choices$text)
      }

      # else do not remember my current input
    } else {
      new_input <- paste0(chatter$input, "\n", input, "\n")
      response <- openai::create_completion(
        prompt = new_input,
        model = chatter$model,
        temperature = chatter$temperature,
        max_tokens = chatter$max_tokens,
        echo = echo, ...
      )
      if (return_response) {
        return(response)
      } else {
        cat(response$choices$text)
      }
    }
  }


  chatter.plot <<- function(input, echo = FALSE, feed = FALSE, run = FALSE, ...) {
    input <- paste0("Use R. Do not include '<code>' in the reply. Only reply with code.\n", input, "\n")
    # if we should feed and plot at the same time
    if (feed) {
      chatter.feed(input)
      response <- openai::create_completion(
        prompt = chatter$input,
        model = chatter$model,
        temperature = chatter$temperature,
        max_tokens = chatter$max_tokens,
        echo = echo, ...
      )
      if (run) {
        eval(parse(text = response$choices$text))
      } else {
        plot <- eval(parse(text = response$choices$text))
        structure(list(code = str2lang(response$choices$text), plot = plot), class = "chatterplot")
      }

      # else do not remember my current input
    } else {
      new_input <- paste0(chatter$input, "\n", input, "\n")
      response <- openai::create_completion(
        prompt = new_input,
        model = chatter$model,
        temperature = chatter$temperature,
        max_tokens = chatter$max_tokens,
        echo = echo, ...
      )
      if (run) {
        eval(parse(text = response$choices$text))
      } else {
        plot <- eval(parse(text = response$choices$text))
        structure(list(code = str2lang(response$choices$text), plot = plot), class = "chatterplot")
      }
    }
  }

  chatter.do <<- function(input, echo = FALSE, feed = FALSE, run = FALSE, ...) {
    input <- paste0("Use R. Do not include '<code>' in the reply. Only reply with code.\n", input, "\n")

    if (feed) {
      chatter.feed(input)

      response <- openai::create_completion(
        prompt = chatter$input,
        model = chatter$model,
        temperature = chatter$temperature,
        max_tokens = chatter$max_tokens,
        echo = echo, ...
      )
      if (run) {
        print(response$choices$text)
        eval(parse(text = response$choices$text))
      } else {
        structure(list(code = str2lang(response$choices$text)), class = "chatterdo")
      }

      # else do not remember my current input
    } else {
      new_input <- paste0(chatter$input, "\n", input, "\n")
      response <- openai::create_completion(
        prompt = new_input,
        model = chatter$model,
        temperature = chatter$temperature,
        max_tokens = chatter$max_tokens,
        echo = echo, ...
      )
      if (run) {
        print(response$choices$text)
        eval(parse(text = response$choices$text))
      } else {
        structure(list(code = str2lang(response$choices$text)), class = "chatterdo")
      }
    }
  }
  cat("\n-> Chatter created.\n\n")
}
