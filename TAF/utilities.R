comp2long <- function(x, measure="length")
{
  if(!any(names(x) == "method"))
    x <- data.frame(method=1, x)

  cols <- c("method", "year", "month", "fleet", "sex", "part")
  rowlab <- apply(x[cols], 1, paste, collapse="|")

  x <- x[grep("[a-z][0-9]+", names(x))]
  names(x) <- substring(names(x), 2)
  x <- as.matrix(x)
  row.names(x) <- rowlab

  comps <- as.data.frame(as.table(x), stringsAsFactors=FALSE)
  vars <- read.table(text=comps$Var1, sep="|")
  comps$Var1 <- NULL
  comps$Var2 <- type.convert(comps$Var2, as.is=TRUE)

  out <- data.frame(vars, comps)
  names(out) <- c(cols, measure, "freq")

  out
}
