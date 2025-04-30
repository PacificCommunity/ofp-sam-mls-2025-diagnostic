comp2long <- function(x, measure=NULL, zero=TRUE)
{
  # Generalized size comps
  if(any(names(x) == "method"))
  {
    method <- TRUE
    if(is.null(measure))
      measure <- "size"
  }
  # Length comps
  else
  {
    method <- FALSE
    x <- data.frame(method=1, x)
    if(is.null(measure))
      measure <- "length"
  }

  # Store variables as a combined string
  cols <- c("method", "year", "month", "fleet", "sex", "part", "Nsamp")
  x$Nsamp <- format(x$Nsamp, trim=TRUE, digits=12)
  rowlab <- apply(x[cols], 1, paste, collapse="|")

  # Prepare composition data
  x <- x[!names(x) %in% cols]
  names(x) <- gsub("[a-z]", "", names(x))
  x <- as.matrix(x)
  row.names(x) <- rowlab

  # Convert composition data to long format
  comp <- as.data.frame(as.table(x), stringsAsFactors=FALSE)
  vars <- read.table(text=comp$Var1, sep="|", col.names=cols)
  comp$Var1 <- NULL
  comp$Var2 <- type.convert(comp$Var2, as.is=TRUE)
  names(comp) <- c(measure, "freq")

  # Combine vars and comp
  out <- data.frame(vars, comp)
  if(!method)
    out$method <- NULL
  if(!zero)
    out <- out[out$freq > 0,]

  out
}
