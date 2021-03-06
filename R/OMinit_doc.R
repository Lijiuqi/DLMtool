#' Copy example OM XL and OM Documentation 
#'
#' @export
#'
#' @examples
#' \dontrun{
#' OMexample()
#' }
OMexample <- function() {
  fromRMD <- system.file("Example_Chile_Hake.Rmd", package="DLMtool")
  tt <- file.copy(fromRMD, getwd(), overwrite = TRUE)
  fromXL <- system.file("Example_Chile_hake.xlsx", package="DLMtool")
  tt <- file.copy(fromXL, getwd(), overwrite = TRUE)
}

#' Initialize Operating Model
#'
#' Generates an Excel spreadsheet and a source.rmd file in the current working directory for 
#' specifying and documenting a DLMtool Operating Model.
#' 
#' @param name The name of the Excel and source.rmd file to be created in the working directory (character). 
#' Use 'example' for a populated example OM XL and documentation file.
#' @param ... Optional DLMtool objects to use as templates: OM, Stock, Fleet, Obs, or Imp objects
#' @param files What files should be created: 'xlsx', 'rmd', or c('xlsx', 'rmd') (default: both)
#' to use as templates for the Operating Model.
#' @param overwrite Logical. Should files be overwritten if they already exist?
#'
#' @return name.xlsx and name.rmd files are created in the working directory.  
#' @export
#' @author A. Hordyk
#'
#' @examples
#' \dontrun{
#' # Create an Excel OM template and rmd file called 'myOM.xlsx' and 'myOM.rmd': 
#' OMinit('myOM')
#' 
#' # Create an Excel OM template and text file called 'myOM.rmd' and 'myOM.rmd', using
#' another OM as a template: 
#' OMinit('myOM', myOM)
#' 
#' # Create an Excel OM template and text file called 'myOM.rmd' and 'myOM.rmd', using
#' the Stock object 'Herring' as a template: 
#' OMinit('myOM', Herring)
#' 
#' # Create an Excel OM template and text file called 'myOM.rmd' and 'myOM.rmd', using
#' the Stock object 'Herring', and Obs object 'Generic_obs' as templates: 
#' OMinit('myOM', Herring, Generic_obs)
#' }
#' 
OMinit <- function(name=NULL, ..., files=c('xlsx', 'rmd'), overwrite=FALSE) {
  files <- match.arg(files, several.ok = TRUE)
  
  if (is.null(name)) stop("Require OM name", call.=FALSE)
  
  if (tolower(name) == 'example') {
    OMexample()
    return(message("Creating Example Files in ", getwd()))
  }
  if (class(name) != 'character') stop("name must be text", call.=FALSE)
 

  ## Write Excel skeleton ####
  if (nchar(tools::file_ext(name)) == 0) {
    nameNoExt <- name
    name <- paste0(name, ".xlsx")
  } else {
    ext <- tools::file_ext(name)
    if (!ext %in% c("xlsx", "xls")) stop("File extension must be 'xlsx' or 'xls'", call.=FALSE)
    nameNoExt <- tools::file_path_sans_ext(name)
  }
  
  InTemplates <- list(...)
  ObTemplates <- list()
  if (length(InTemplates) >0) {
    inclasses <- unlist(lapply(InTemplates, class))
    for (x in seq_along(inclasses)) {
      if (!inclasses[x] %in% c("Stock", "Fleet", "Obs", "Imp", "OM")) stop(InTemplates[[x]], " is not a valid DLMtool object")
    }
    isOM <- which(inclasses == "OM")
    if (length(isOM)>0) {
      message("\nUsing OM Template")
      ObTemplates$Stock <- SubOM(InTemplates[[isOM]], "Stock")
      if (is.na(ObTemplates$Stock@Name) || nchar(ObTemplates$Stock@Name)==0) ObTemplates$Stock@Name <- InTemplates[[isOM]]@Name
      ObTemplates$Fleet <- SubOM(InTemplates[[isOM]], "Fleet")
      if (is.na(ObTemplates$Fleet@Name) || nchar(ObTemplates$Fleet@Name)==0) ObTemplates$Fleet@Name <- InTemplates[[isOM]]@Name
      ObTemplates$Obs <- SubOM(InTemplates[[isOM]], "Obs")
      if (is.na(ObTemplates$Obs@Name) || nchar(ObTemplates$Obs@Name)==0) ObTemplates$Obs@Name <- InTemplates[[isOM]]@Name
      ObTemplates$Imp <- SubOM(InTemplates[[isOM]], "Imp")
      if (is.na(ObTemplates$Imp@Name) || nchar(ObTemplates$Imp@Name)==0) ObTemplates$Imp@Name <- InTemplates[[isOM]]@Name
      # ObTemplates$OM <- c(InTemplates[[isOM]]@Name,
      #                     InTemplates[[isOM]]@Agency,
      #                     InTemplates[[isOM]]@Region,
      #                     InTemplates[[isOM]]@Sponsor,
      #                     InTemplates[[isOM]]@Latitude,
      #                     InTemplates[[isOM]]@Longitude,
      #                     InTemplates[[isOM]]@nsim,
      #                     InTemplates[[isOM]]@proyears,
      #                     InTemplates[[isOM]]@interval,
      #                     InTemplates[[isOM]]@pstar,
      #                     InTemplates[[isOM]]@maxF,
      #                     InTemplates[[isOM]]@reps)
    } else {
      for (x in seq_along(inclasses)) {
        if (inclasses[x] == 'Stock') ObTemplates$Stock <- InTemplates[[x]]
        if (inclasses[x] == 'Fleet') ObTemplates$Fleet <- InTemplates[[x]]
        if (inclasses[x] == 'Obs') ObTemplates$Obs <- InTemplates[[x]]
        if (inclasses[x] == 'Imp') ObTemplates$Imp <- InTemplates[[x]]
      }
      nm <- names(ObTemplates)  
      message("\n\nUsing Object Templates:")
      for (X in nm) {
        message(ObTemplates[[X]]@Name)
      }
    }
  }
  
  if ('xlsx' %in% files) {
   
    # Copy xlsx file over to working directory 
    # Copy the Excel File ####
    message("Creating ", name, " in ", getwd())
    path <- system.file("OM.xlsx", package = "DLMtool")
    pathout <- gsub("OM.xlsx", name, path)
    pathout <- gsub(dirname(pathout), getwd(), pathout)
    
    # Check if file exists 
    exist <- file.exists(pathout)
    if (exist & !overwrite) stop(name, " alread exists in working directory. Use 'overwrite=TRUE' to overwrite", 
                                 call.=FALSE)
    copy <- file.copy(path, pathout, overwrite = overwrite)
    if (!copy) stop("Excel file not copied from ", path)
    
    # Copy over templates - if used ####
    chck <- Sys.which("zip") # requires 'zip.exe' on file path
    if (nchar(chck) <1) {
      message('zip application is required. A possible workaround is:')
      message('path <- Sys.getenv("PATH")')
      message('Sys.setenv("PATH" = paste(path, "path_to_zip.exe", sep = ";"))')
      stop("Can't uses templates without zip application", call.=FALSE)
    }
    
    # loop through slot values if Obj template provided
    wb <- openxlsx::loadWorkbook(name)
    names <- c("Stock", "Fleet", "Obs", "Imp")
    for (objname in names) {
      if (!is.null(ObTemplates[objname])) {
        obj <- ObTemplates[objname][[1]]
        slots <- slotNames(obj)
        
        for (sl in seq_along(slots)) {
          val <- slot(obj, slotNames(objname)[sl])
          ln <- length(val)
          if (ln >0 && !is.na(ln)) {
            df <- data.frame(t(val))
            openxlsx::writeData(wb, sheet = objname, x = df, 
                                startCol = 2, startRow = sl+1,
                                colNames = FALSE, rowNames = FALSE, 
                                withFilter = FALSE,
                                keepNA = FALSE)         
          }
          
        }
        openxlsx::setColWidths(wb, sheet = objname, cols = 1, widths = 'auto')
      }
    }
    
    # OM tab not currently updated
    openxlsx::saveWorkbook(wb, name, overwrite = TRUE)
    
  }
  

  if ('rmd' %in% files) { 
    # RMD File ####
    rmdname <- paste0(nameNoExt, '.rmd')
    message("Creating ", rmdname, " in ", getwd())
    path <- system.file("OM.rmd", package = "DLMtool")
    if (nchar(path) <1) stop("OM.rmd not found in DLMtool package")
    pathout <- gsub("OM.rmd", rmdname, path)
    pathout <- gsub(dirname(pathout), getwd(), pathout)
    
    # Check if file exists 
    exist <- file.exists(pathout)
    if (exist & !overwrite) stop(rmdname, " alread exists in working directory. Use 'overwrite=TRUE' to overwrite", 
                                 call.=FALSE)
    copy <- file.copy(path, pathout, overwrite = overwrite)
    if (!copy) stop("Rmd file not copied from ", path)
    
    # Copy over templates - if used ####
    if (length(ObTemplates)>0) {
      names <- c("Stock", "Fleet", "Obs", "Imp")
      textIn <- readLines(rmdname)
      for (objname in names) {
        if (!is.null(ObTemplates[objname])) {
          obj <- ObTemplates[objname][[1]]
          slots <- slotNames(obj)
          
          for (sl in slots) {
            if (!sl %in% c("Name", "Source")) {
              lineno <- grep(paste0("^## ", sl, "$"), textIn)
              textIn[lineno+1] <- paste("Borrowed from:", obj@Name)
            }
            
          }
        }
      }
      writeLines(textIn, con = rmdname, sep = "\n", useBytes = FALSE)
    }
  } 
  
}


#' Load OM from Excel file
#' 
#' Imports an OM from a correctly formatted Excel file. Create the Excel spreadsheet template
#' using `OMinit` and document each slot in the corresponding text file.
#' 
#' An error message will alert if any slots are missing values, or if the Excel file is missing
#' the required tabs.
#'
#' @param name Name of the OM Excel file in the current working directory.
#' @param cpars An optional list of custom parameters (single parameters are a vector nsim 
#' long, time series are a matrix nsim rows by nyears columns)
#' @param msg Should messages be printed?
#'
#' @return An object of class OM
#' @export
#' @author A. Hordyk
#'
#' @examples 
#' \dontrun{
#' OMinit('myOM', templates=list(Stock='Herring', Fleet='Generic_Fleet', Obs='Generic_Obs',
#' Imp='Perfect_Imp'), overwrite=TRUE)
#' myOM <- XL2OM('myOM.xlsx')
#' 
#' }
XL2OM <- function(name=NULL, cpars=NULL, msg=TRUE) {
  

  # Load the Excel File ####
  if (is.null(name)) {
    fls <- list.files(pattern=".xlsx", ignore.case = TRUE)
    fls <- fls[!grepl('~', fls)]
    if (length(fls) == 0) stop('Name not provided and no .xlsx files found.', call.=FALSE)
    if (length(fls) > 1) stop("Name not provided and multiple .xlsx files found", call.=FALSE)
    name <- fls
  }
  
  if (class(name) != 'character') stop("file name must be provided", call.=FALSE)

  if (nchar(tools::file_ext(name)) == 0) {
    xl.fname1 <- paste0(name, ".xlsx")
    xl.fname2 <- paste0(name, ".xls")
    fls <- file.exists(c(xl.fname1, xl.fname2))
    if (sum(fls) == 0) stop(xl.fname1, " or ", xl.fname2, " not found")
    if (sum(fls) > 1) stop(name, " found with multiple extensions. Specify file extension.", call.=FALSE)
    name <- c(xl.fname1, xl.fname2)[fls]
  }
  if (!file.exists(name)) stop(name, " not found", call.=FALSE) 
  message("Reading ", name)
  sheetnames <- readxl::excel_sheets(name)  # names of the sheets 
  reqnames <- c("OM", "Stock", "Fleet", "Obs", "Imp") 
  ind <- which(!reqnames%in% sheetnames)
  if (length(ind)>0) stop("Sheets: ", paste(reqnames[ind], ""), "not found in ", name, call.=FALSE)
  
  count <- 1
  tempObj <- vector("list", 4)
  for (obj in c("Stock", "Fleet", "Obs", "Imp")) {
    sht <- as.data.frame(readxl::read_excel(name, sheet = obj, col_names = FALSE))
    rows <- sht[,1] 
    rows <- rows[!rows == "Slot"]
    ind <- which(!rows %in% slotNames(obj))
    if (length(ind)>0) {
      warning(paste(rows[ind], ""), "are not valid slots in object class ", obj)
    }
    
    if (all(dim(sht) == 0)) stop("Nothing found in sheet: ", obj, call.=FALSE)
    tmpfile <- tempfile(fileext=".csv")
    writeCSV2(inobj = sht, tmpfile, objtype = obj)
    if (ncol(sht)<2) {
      unlink(tmpfile)
      stop("No parameter values found in Sheet ", obj, call.=FALSE)
    } else {
      tempObj[[count]] <- new(obj, tmpfile)  
    }
    unlink(tmpfile)
    count <- count + 1
  }
  
  # Operating Model
  OM <- new("OM", Stock = tempObj[[1]], Fleet = tempObj[[2]], 
            Obs = tempObj[[3]], Imp=tempObj[[4]])
  
  # Read in the OM sheet
  sht <- as.data.frame(readxl::read_excel(name, sheet = "OM", col_names = FALSE))
  dat <- sht # sht[,1:2] 
  dat <- dat[which(dat[,1] != "Slot"),]
  # if (ncol(sht)>2) warning("More than two columns found in Sheet OM. Values in columns C+ are ignored")
  if (ncol(sht)<2) {
    message("No values found for OM slots in Sheet OM. Using defaults")
  } else {
    for (xx in 1:nrow(dat)) {
      val <- dat[xx, 2:ncol(dat)]
      if (length(val)) {
        if (!dat[xx,1] %in% c("Name", "Agency", "Region", "Sponsor")) {
          options(warn=-1)
          val <- as.numeric(val)
          options(warn=1)
          val <- val[!is.na(val)]
          if (.hasSlot(OM, dat[xx,1])) slot(OM, dat[xx, 1]) <- val
        } else  {
          val <- val[!is.na(val)]
          if (.hasSlot(OM, dat[xx,1])) slot(OM, dat[xx, 1]) <- val
        }
        
      } else{
        message("No value found for OM slot ", dat[xx,1], ". Using default: ", slot(OM, dat[xx, 1]))
      }
    }
  }
  
  if (!is.null(cpars)) {
    if (class(cpars) == "list") {
      OM@cpars <- cpars
    } else {
      stop("'cpars' must be a list", call.=FALSE)
    }
  }
  ChkObj(OM)
  if (msg) {
    message('OM successfully imported\n')
    message("Document OM slots in .rmd file (probably ", tools::file_path_sans_ext(name), ".rmd),
  and run 'OMdoc' if OM parameter values have changed." )
  }

  OM
}





#' Generate OM Documentation Report
#'
#' @param OM An object of class 'OM' or the name of an OM xlsx file 
#' @param rmd.source Optional. Name of the source.rmd file corresponding to the 'OM'. Default assumption
#' is that the file is 'OM@Name.Rmd'
#' @param overwrite Logical. Should existing files be overwritten?
#' @param out.file Optional. Character. Name of the output file. Default is the same as the text file.
#' @param inc.plot Logical. Should the plots be included?
#' @param render Logical. Should the document be compiled? May be useful to turn off if 
#' there are problems with compililing the Rmd file.
#' @param output Character. Output file type. Default is 'html_document'. 'pdf_document' is available
#' but may require additional software and have some formatting issues.
#' @param openFile Logical. Should the compiled file be opened in web browser?
#'
#' @return Creates a Rmarkdown file and compiles a HTML report file in the working directory.
#' @export
#' @importFrom methods getSlots
#' @importFrom knitr kable
#' @author A. Hordyk
#' @examples 
#' \dontrun{
#' OMinit('myOM', templates=list(Stock='Herring', Fleet='Generic_Fleet', Obs='Generic_Obs',
#' Imp='Perfect_Imp'), overwrite=TRUE)
#' myOM <- XL2OM('myOM.xlsx')
#' OMdoc(myOM)
#' }
OMdoc <- function(OM=NULL, rmd.source=NULL, overwrite=FALSE, out.file=NULL,  
                  inc.plot=TRUE, render=TRUE, output="html_document", openFile=TRUE ) {
  # markdown compile options
  toc=TRUE; color="blue";  theme="flatly"
  OMXLname <- NULL
  if (class(OM) == "OM") {
    # nothing
  } else if (class(OM) == 'character') {
    OMXLname <- OM
    OM <- XL2OM(OM, msg=FALSE)
  } else if (is.null(OM)) {
    fls <- list.files(pattern=".xlsx", ignore.case=TRUE)
    fls <- fls[!grepl('~', fls)]
    if (length(fls)==1) OM <- XL2OM(fls, msg=FALSE)
    if (length(fls)>1) stop('argument "OM" not provided and multiple .xlsx files in working directory', call.=FALSE)
  } else stop('OM must be class "OM" or name of OM xlsx file.', call.=FALSE)
  
  if (is.null(OM)) stop('OM not imported. Is the name correct?', call.=FALSE)
  ## Read in Rmd.source file ####
  if (is.null(rmd.source)) {
    rmd.source <- list.files(pattern=".rmd", ignore.case=TRUE)
    if (length(rmd.source) == 0) stop("rmd.source' not specified and no .rmd files found in working directory", call.=FALSE)
    if (length(rmd.source) == 1) {
      # message("rmd.source not specified. Reading ", rmd.source, " found in working directory")
      textIn <- readLines(rmd.source)
    } else {
      NoExt <- tools::file_path_sans_ext(rmd.source)
      if (!is.null(OMXLname)) ind <- which(tolower(NoExt) == tolower(paste0(OMXLname, "_source")))
      if (is.null(OMXLname)) ind <- which(tolower(NoExt) == tolower(paste0(OM@Name, "_source")))
      if (length(ind) > 0) {
        rmd.source <- rmd.source[ind]
        message("Reading ", rmd.source)
        textIn <- readLines(rmd.source)
      } else {
        stop("'rmd.source' not specified and multiple .rmd files found in working directory", call.=FALSE)
      }
    }
  } else {
    if (nchar(tools::file_ext(rmd.source)) == 0) {
      rmd.source <- paste0(rmd.source, ".rmd")
    } else if (tools::file_ext(rmd.source) != "rmd") stop("rmd.source extension must be rmd", call.=FALSE)
    
    if (!file.exists(rmd.source)) stop(rmd.source, " not found in working directory", call.=FALSE)
    message("Reading ", rmd.source)
    textIn <- readLines(rmd.source)
  }
  
  ## Create Markdown file ####
  if (!dir.exists('build')) {
    dir.create('build')
    tt <- file.create('build/readme.txt')
    cat("This directory was created by DLMtool function OMdoc\n\n", sep="", append=TRUE, file='build/readme.txt') 
    cat("Files in this directory are used to generate the OM report.\n\n", sep="", append=TRUE, file='build/readme.txt') 
  } 
  
  if(dir.exists("images")) {
    dir.create('build/images', showWarnings = FALSE)
    cpy <- file.copy('images', 'build', overwrite=TRUE, recursive = TRUE)
  }

  if (is.null(out.file)) out.file <- tools::file_path_sans_ext(rmd.source)
  # out.file <- gsub("_source", "_compiled", out.file)
  
  RMDfile <- paste0("build/", out.file, ".Rmd")
  # if (file.exists(RMDfile) & !overwrite) {
  #   stop(RMDfile, " already exists.\n Provide a different output file name ('out.file') or use 'overwrite=TRUE'")
  # } else {
  #   message('Writing ', RMDfile)
  tt <- file.create(RMDfile)
  # }

  
  ## Write YAML ####
  ind <- grep("^# Title", textIn)
  if (length(ind)>0) {
    title <- trimws(textIn[ind+1])
    if (nchar(title) == 0) title <- paste("Operating Model:", OM@Name)
  } else {
    title <- paste("Operating Model:", OM@Name)
  }
  
  ind <- grep("^# Subtitle", textIn)
  if (length(ind)>0) {
    subtitle <- trimws(textIn[ind+1])
    if (nchar(subtitle) == 0) subtitle <- NULL
  } else {
    subtitle <- NULL
  }
  
  ind <- grep("# Author", textIn)
  if (length(ind)>0) {
    temp <- min(which(nchar(textIn[(ind+1):length(textIn)]) == 0))
    if (temp > 1) {
      authors <- trimws(textIn[(ind+1):(ind+temp-1)])
    } else {
      authors <- "No author provided"
    }
  } else {
    authors <- "No author provided"
  }
  
  ind <- grep("# Date", textIn)
  if (length(ind)>0) {
    date <- trimws(textIn[(ind+1)])
    if (grepl("Optional. Date", date)) date <- NULL
  } else {
    date <- NULL
  }
  
  cat("---\n", sep="", append=TRUE, file=RMDfile)
  cat("title: '", title, "'\n", append=TRUE, file=RMDfile, sep="") 
  if (!is.null(subtitle)) cat("subtitle: '", subtitle, "'\n", append=TRUE, file=RMDfile, sep="")
  if (length(authors) > 1) {
    cat("author:", "\n", append=TRUE, file=RMDfile, sep="")
    for (xx in 1:length(authors)) {
      # if (!any(is.null(affiliation)) && affiliation[xx] != 'NA') {
      #   cat("- ", authors[xx], "^[", affiliation[xx], "]\n", append=TRUE, file=RMDfile, sep="")  
      # } else {
      #   cat("- ", authors[xx], "\n", append=TRUE, file=RMDfile, sep="")  
      # }
      cat("- ", authors[xx], "\n", append=TRUE, file=RMDfile, sep="")
      
    }
  } else {
    cat("author: ", authors, "\n", append=TRUE, file=RMDfile, sep="")
    # if (is.null(affiliation)) {
    #   cat("author: ", authors, "\n", append=TRUE, file=RMDfile, sep="")
    # } else {
    #   cat("author: ", authors, "^[", affiliation, "]\n", append=TRUE, file=RMDfile, sep="")
    # }
    
  }
  if (is.null(date)) date <- format(Sys.time(), '%d %B %Y')
  cat("date: ", date, "\n", append=TRUE, file=RMDfile, sep="")
  
  if (toc) {
    cat("output: ", "\n", append=TRUE, file=RMDfile, sep="")  
    cat("   ", output, ":", "\n", append=TRUE, file=RMDfile, sep="")  
    cat("     toc: true\n", append=TRUE, file=RMDfile, sep="")  
    cat("     toc_depth: 3\n", append=TRUE, file=RMDfile, sep="")  
    if (output == "html_document") {
      cat("     toc_float: true\n", append=TRUE, file=RMDfile, sep="")
      cat("     theme: ", theme, "\n", append=TRUE, file=RMDfile, sep="")
    }

    
  } else {
    cat("output: ", output, "\n", append=TRUE, file=RMDfile, sep="")
  }
  cat("---\n\n", sep="", append=TRUE, file=RMDfile) 
  

  ## knitr options ####
  # cat("```{r setup, include=FALSE}\n", append=TRUE, file=RMDfile, sep="")
  # cat("library(knitr)\n", append=TRUE, file=RMDfile, sep="")
  # cat("opts_chunk$set(dev = 'pdf')\n", append=TRUE, file=RMDfile, sep="")
  # cat("```\n", append=TRUE, file=RMDfile, sep="")

  ## Generate Sampled Parameters ####
  
  Pars <- NULL
  out <- NULL
  if (inc.plot) {
    
    # --- Generate Historical Samples ----
    # Only required if the OM has changed #
    runSims <- FALSE
    fileName <- OM@Name
    fileName <- gsub(" ", "", gsub("[[:punct:]]", "", fileName))
    if (nchar(fileName)>15) fileName <-  substr(fileName, 1, 15)
      
    if (file.exists(paste0('build/', fileName, '.dat'))) {
      # OM has been documented before - check if it has changed
      testOM <- readRDS(paste0("build/", fileName, '.dat'))
      if (class(testOM) == 'OM') {
        # check if OM has changed 
        changed <- rep(FALSE, length(slotNames(OM)))
        for (sl in seq_along(slotNames(OM))) {
      
          oldOM <- slot(OM, slotNames(OM)[sl])
          newOM <- slot(testOM, slotNames(OM)[sl])
          if (class(oldOM) !='character') {
            if (class(oldOM) != 'list') {
              if (length(oldOM)<1 || !is.finite(oldOM)) oldOM <- 0
              if (length(newOM)<1 || !is.finite(newOM)) newOM <- 0
              if (any(oldOM != newOM)) changed[sl] <- TRUE
            } else {
              if (length(oldOM) != length(newOM)) {
                changed[sl] <- TRUE
              } else if (length(oldOM)>0){
                for (xx in 1:length(oldOM)) {
                  if(any(oldOM[[xx]] != newOM[[xx]]))changed[sl] <- TRUE
                  
                }
              }
            }
          }
        }
        if (sum(changed)>0) runSims <- TRUE 
        if (sum(changed) == 0) {
          out <-  readRDS(paste0('build/', fileName, 'Hist.dat'))
          Pars <- c(out$SampPars, out$TSdata, out$MSYs)  
        }
      } else {
        file.remove(paste0('build/',fileName, '.dat'))
        runSims <- TRUE
      }
     
    } else{
      saveRDS(OM, file=paste0('build/', fileName, '.dat'))
      runSims <- TRUE
    }
    
    if (runSims) {
      message("\nRunning Historical Simulations\n")
      OM <- updateMSE(OM) # update and add missing slots with default values
      if (OM@nsim > 48) setup()
      out<- runMSE(OM,Hist=T)
      Pars <- c(out$SampPars, out$TSdata, out$MSYs)  
      saveRDS(out, file=paste0('build/', fileName, 'Hist.dat'))
    }
  }
  
  ## Input text ####
  # ind <- which(unlist(lapply(textIn, nchar)) == 0) # delete empty lines 
  # if (length(ind) > 0) textIn <- textIn[-ind]
  ind <- grep("# Introduction", textIn)
  if (length(ind)>1) stop("# Introduction heading found more than once", call.=FALSE)
  if (length(ind)>0) {
    textIn <- textIn[ind:length(textIn)]
  } else {
    ind <- grep("# Stock Parameters", textIn)
    if (length(ind)>1) stop("# Stock Parameters heading found more than once", call.=FALSE)
    if (length(ind) == 0) stop("# Stock Parameters not found", call.=FALSE)
    textIn <- textIn[ind:length(textIn)]
  }
  
  message("Writing markdown file")
  ## Introduction ####
  writeSection(class="Intro", OM, textIn, RMDfile, color=color, inc.plot=inc.plot)
  
  ## OM Details ####
  OMdesc <- DLMtool::OMDescription
  cat("# Operating Model \n", append=TRUE, file=RMDfile, sep="")
  # Taxonomic Info and Location ####
  if (.hasSlot(OM, 'Species') && !is.na(OM@Species)) {
    cat("## Species Information \n\n", append=TRUE, file=RMDfile, sep="")
    cat("**Species**: *", OM@Species, "*\n\n", append=TRUE, file=RMDfile, sep="")
    cat("**Management Agency**: ", OM@Agency, "\n\n", append=TRUE, file=RMDfile, sep="")
    cat("**Region**: ", OM@Region, "\n\n", append=TRUE, file=RMDfile, sep="")
    if (length(OM@Sponsor)>0) cat("**Sponsor**: ", OM@Sponsor, "\n\n", append=TRUE, file=RMDfile, sep="")
    if (length(OM@Latitude)>0) {
      lat <- paste0(OM@Latitude, sep="", collapse=", ")
      cat("**Latitude**: ", lat, "\n\n", append=TRUE, file=RMDfile, sep="")
    }
    if (length(OM@Longitude)>0) {
      long <- paste0(OM@Longitude, sep="", collapse=", ")
      cat("**Longitude**: ", long, "\n\n", append=TRUE, file=RMDfile, sep="")
    }
  }
  
  cat("## OM Parameters \n", append=TRUE, file=RMDfile, sep="")
  cat("**OM Name**: ", OMdesc$Description[OMdesc$Slot =='Name'], ": ", "<span style='color:", color, "'>", " ", OM@Name, "</span>", "\n\n", append=TRUE, file=RMDfile, sep="")
  
  cat("**nsim**: ", OMdesc$Description[OMdesc$Slot =='nsim'], ": ", "<span style='color:", color, "'>", " ", OM@nsim, "</span>", "\n\n", "\n\n", append=TRUE, file=RMDfile, sep="")
  
  cat("**proyears**: ", OMdesc$Description[OMdesc$Slot =='proyears'], ": ", "<span style='color:", color, "'>", " ", OM@proyears, "</span>", "\n\n", "\n\n", "\n\n", append=TRUE, file=RMDfile, sep="")

  cat("**interval**: ", OMdesc$Description[OMdesc$Slot =='interval'], " ", "<span style='color:", color, "'>", " ", OM@interval, "</span>", "\n\n",append=TRUE, file=RMDfile, sep="")
  
  cat("**pstar**: ", OMdesc$Description[OMdesc$Slot =='pstar'], ": ", "<span style='color:", color, "'>", " ", OM@pstar, "</span>", "\n\n",append=TRUE, file=RMDfile, sep="")
  
  cat("**maxF**: ", OMdesc$Description[OMdesc$Slot =='maxF'], ": ", "<span style='color:", color, "'>", " ", OM@maxF, "</span>", "\n\n", append=TRUE, file=RMDfile, sep="")
  
  cat("**reps**: ", OMdesc$Description[OMdesc$Slot =='reps'], " ", "<span style='color:", color, "'>", " ", OM@reps, "</span>", "\n\n", append=TRUE, file=RMDfile, sep="")
 
  cat("**Source**: ", OMdesc$Description[OMdesc$Slot =='Source'], "\n\n", "<span style='color:", color, "'>", " ", OM@Source, "</span>", "\n\n", append=TRUE, file=RMDfile, sep="")
  
  
  useCpars <- length(OM@cpars) >0 
  ## Cpars ####
  cat(".")
  if (useCpars) writeSection(class="cpars", OM, textIn, RMDfile, color=color, 
                             inc.plot=inc.plot)

  ## Stock Parameters ####
  cat(".")
  writeSection(class="Stock", OM, textIn, RMDfile, color=color, inc.plot=inc.plot)
  
  ## Fleet Parameters ####
  cat(".")
  writeSection(class="Fleet", OM, textIn, RMDfile, color=color, inc.plot=inc.plot)
  
  ## Observation Parameters ####
  cat(".")
  writeSection(class="Obs", OM, textIn, RMDfile, color=color, inc.plot=inc.plot)
  
  ## Implementation Parameters ####
  cat(".")
  writeSection(class="Imp", OM, textIn, RMDfile, color=color, inc.plot=inc.plot)
  
  ## OM Plots ####
  if (inc.plot) {
    cat("# OM Plots\n\n", sep="", append=TRUE, file=RMDfile) # write heading
    cat("```{r plotOM, echo=FALSE, fig.asp=2}\n", append=TRUE, file=RMDfile, sep="")
    cat("plot.OM(out)\n", append=TRUE, file=RMDfile, sep="")
    cat("```\n\n\n", append=TRUE, file=RMDfile, sep="")

  }
  
  
  ## References ####
  cat(".")
  writeSection(class="References", OM, textIn, RMDfile, color=color, inc.plot=inc.plot)
  
  ## Render Markdown ####
  if (render) {
    RMDfileout <- gsub("_compiled", "", tools::file_path_sans_ext(RMDfile))
    if (output == "html_document") RMDfileout <- paste0(unlist(strsplit(RMDfileout, "/"))[2], ".html")
    if (output == "pdf_document") RMDfileout <- paste0(unlist(strsplit(RMDfileout, "/"))[2], ".pdf")

    message("\n\nRendering markdown document as ", RMDfileout)
    EffYears <- seq(from=(OM@CurrentYr -  OM@nyears + 1), to=OM@CurrentYr, length.out=length(OM@EffYears))
    EffYears <- round(EffYears,0)
    Effvals <- data.frame(EffYears=EffYears, EffLower=OM@EffLower, EffUpper=OM@EffUpper)
    params <- list(OM=OM, Pars=Pars, Effvals=Effvals, out=out)
    rmarkdown::render(input=RMDfile, output_file=RMDfileout, output_format=output, output_dir=getwd(), param=params)
    
    if (openFile) utils::browseURL(file.path(getwd(), RMDfileout))
    
  } else {
    
  }
  
}




# Text templates for the OM documentation ####
Template <- function(type=c("Stock", "Fleet", "Obs", "Imp")) {
  type <- match.arg(type)
  if (type == "Stock") mat <- 
      matrix(c("Mortality and age:  maxage, R0, M, M2, Mexp, Msd, Mgrad",
               "Recruitment: h, SRrel, Perr, AC",
               "Non-stationarity in stock productivity: Period, Amplitude",
               "Growth: Linf, K, t0, LenCV, Ksd, Kgrad, Linfsd, Linfgrad",
               "Maturity: L50, L50_95",
               "Stock depletion: D",
               "Length-weight conversion parameters: a, b",
               "Spatial distribution and movement: Size_area_1, Frac_area_1, Prob_staying",
               "Discard Mortality: Fdisc "), ncol=1)
  if (type == "Fleet") mat <- 
      matrix(c(
        "Historical years of fishing, spatial targeting: nyears, Spat_targ",
        "Trend in historical fishing effort (exploitation rate), interannual variability in fishing effort: EffYears, EffLower, EffUpper, Esd",
        "Annual increase in catchability, interannual variability in catchability: qinc, qcv",
        "Fishery gear length selectivity: L5, LFS, Vmaxlen, isRel",
        "Fishery length retention: LR5, LFR, Rmaxlen, DR",
        "Time-varying selectivity: SelYears, AbsSelYears, L5Lower, L5Upper, LFSLower, LFSUpper, VmaxLower, VmaxUpper",
        "Current Year: CurrentYr"), ncol=1)
  if (type == "Obs") mat <- 
      matrix(c(
        "Catch statistics: Cobs, Cbiascv, CAA_nsamp, CAA_ESS, CAL_nsamp, CAL_ESS",
        "Index imprecision, bias and hyperstability: Iobs, Ibiascv, Btobs, Btbiascv, beta",
        "Bias in maturity, natural mortality rate and growth parameters: LenMbiascv, Mbiascv, Kbiascv,t0biascv, Linfbiascv",
        "Bias in length at first capture, length at full selection: LFCbiascv, LFSbiascv",
        "Bias in fishery reference points, unfished biomass, FMSY, FMSY/M ratio, biomass at MSY relative to unfished: FMSYbiascv, FMSY_Mbiascv, BMSY_B0biascv",
        "Management targets in terms of the index (i.e., model free), the total annual catches and absolute biomass levels: Irefbiascv, Crefbiascv, Brefbiascv",
        "Depletion bias and imprecision: Dbiascv, Dobs",
        "Recruitment compensation and trend: hbiascv, Recbiascv"), ncol=1)
        # "Currently unused observation processes - bias in unfished biomass, intrinsic rate of increase, annual increase in fishing efficiency and age at 50% vulnerability, bias and imprecision in current fishing rate, bias in maximum age: B0cv, rcv, Fcurbiascv, Fcurcv, maxagecv"), ncol=1)
  if (type == "Imp") mat <-
      matrix(c(
        "Output Control Implementation Error: TACFrac, TACSD",
        "Effort Control Implementation Error: TAEFrac, TAESD", 
        "Size Limit Control Implementation Error: SizeLimFrac, SizeLimSD"), ncol=1)
 
  # Check slots 
  Slots <- names(methods::getSlots(type))
  for (X in Slots) {
    tt <- grep(paste0("\\<", X, "\\>"), mat) 
    if (X != "Name" && X != "Source" && X!="Species" && X!="Latitude" && X!='Longitude') {
      if (length(tt) < 1) stop("slot ", X, " not found in ", type, " template", call.=FALSE)
      if (length(tt) > 1) stop("slot ", X, " found multiple times in ", type, " template", call.=FALSE)    
    }
  }
  return(mat)
}


writeSection <- function(class=c("Intro", "Stock", "Fleet", "Obs", "Imp", "References", "cpars"), OM,
                         textIn, RMDfile, color, inc.descript=TRUE, inc.plot=TRUE) {
  class <- match.arg(class)
  
  useCpars <- length(OM@cpars) > 0
  
  
  fLH <- grep("^#[^##]", textIn)
  fstH <- trimws(gsub("#", "", textIn[fLH])) # first level headings
  fstHmd <- trimws(textIn[fLH]) # first level headings
  
  if (class == "Intro") {
    intro <- which(trimws(gsub("#", "", fstH)) == "Introduction")
    if (intro == 0) stop("# Introduction heading not found", call.=FALSE)
    if (length(intro) == 1) {
      cat(fstHmd[intro], "\n\n", sep="", append=TRUE, file=RMDfile) # write first heading
      for (ll in (intro+1):(fLH[intro+1] - 1)) {
        cat(textIn[ll], "\n\n", sep="", append=TRUE, file=RMDfile) # write intro paragraphs
      }
    } else {
      stop("More than one section # Introduction", call.=FALSE)
    }
    
  } else if (class == "References") {
    refText <- which(trimws(gsub("#", "", fstH)) == "References")
    if (length(refText) == 1) {
      cat("# References\n\n", sep="", append=TRUE, file=RMDfile) # write heading
      st <- which(textIn == '# References')
      end <- length(textIn)
      if (st+1 < end) {
        for (ll in (st+1):(end)) {
          cat(textIn[ll], "\n\n", sep="", append=TRUE, file=RMDfile) # 
        }   
      }
      
    } else stop("More than one section # References", call.=FALSE)
  } else if (class == "cpars") {
    cparstext <- which(trimws(gsub("#", "", fstH)) == "Custom Parameters")
    if (length(cparstext) == 1) {
      # get cpars text 
      cat("# Custom Parameters\n\n", sep="", append=TRUE, file=RMDfile) # write heading
      
      st <- which(textIn == '# Custom Parameters')
      end <- textIn %in% paste0('# ', fstH)
      temp <- which(textIn[end] != "# Custom Parameters") 
      temp <- min(temp[temp>cparstext])
      end <- which(textIn == paste0("# ", fstH[temp]))
      for (ll in (st+1):(end - 1)) {
        cat(textIn[ll], "\n\n", sep="", append=TRUE, file=RMDfile) # write cpars paragraphs
      }
    } 
    if (length(cparstext) > 1) stop("More than one section # Custom Parameters", call.=FALSE)
    
  } else {
    # Write class heading 
    st <- which(trimws(gsub("#", "", textIn)) == paste(class, "Parameters"))
    sta <- which(fstH == paste(class, "Parameters"))
    if (length(st) > 1) stop("Multiple '# ", class, " Parameters' headings in document.", call.=FALSE)
    if (length(st) < 1) stop("'# ", class, " Parameters' heading not found in document.", call.=FALSE)
    cat("# ", class, " Parameters \n\n", append=TRUE, file=RMDfile, sep="")
    
    # Find second level headings and check that they match slots in class
    bg <- st+1
    end <- fLH[sta+1]-1
    if (is.na(end)) end <- length(textIn)
    Text <- textIn[bg:end]
    scLHloc <- grep("^##[^###]", Text) # second level headings
    scLHmd <- Text[scLHloc]
    scLH <- trimws(gsub("##", "",scLHmd))
    
    Slots <- slotNames(class)
    if (any(!scLH %in% Slots)) {
      invalid <- scLH[!scLH %in% Slots]
      stop("Invalid second level headings (must match slots in class ", class, "): ", paste(invalid, ""), call.=FALSE)
    }
    
    # check for text after class heading 
    preText <- textIn[bg:(bg+scLHloc[1]-2)]
    if (any(nchar(preText)>0)) {
      cat(preText, "\n\n", append=TRUE, file=RMDfile, sep="")
    }
  
    
    # Get template for class section 
    ClTemp <- Template(class)
    
    # loop through template and write section 
    for (rr in 1:nrow(ClTemp)) {
      if(grepl("^Currently unused", ClTemp[rr,1])) {
        temptext <- trimws(unlist(strsplit(ClTemp[rr,], "-")))
        cat("### ", temptext[1], "\n\n", append=TRUE, file=RMDfile, sep="")
        cat("*", temptext[2], "*\n\n", append=TRUE, file=RMDfile, sep="")
      } else {
        slots <- trimws(unlist(strsplit(strsplit(ClTemp[rr,], ":")[[1]][2], ",")))
        cat("### ", ClTemp[rr,], "\n\n", append=TRUE, file=RMDfile, sep="")
        for (sl in slots) {
          # get slot value if not in cpars 
          if (useCpars && sl %in% names(OM@cpars)) {
            val <- range(OM@cpars[[sl]])
            val <- round(val,2)
            used <- TRUE
            val <- gsub('"', "", paste(val, collapse="\", \""))
            valtext <- paste0("Specified in cpars: ", "<span style='color:", color, "'>", " ", trimws(val), "</span>", "\n\n")
          } else {
            val <- slot(OM, sl)
            if (is.numeric(val)) val <- round(val,2)
            used <- length(val)>0 && !is.na(val) && !is.null(val) # is the slot used?
            if (used) {
              val <- gsub('"', "", paste(val, collapse="\", \""))
              valtext <- paste0("Specified Value(s): ", "<span style='color:", color, "'>", " ", trimws(val), "</span>", "\n\n")
            } else {
              valtext <- val
            }           
          }
          
          loc <- which(scLH == sl)
          if (length(loc) > 0) {
            bg <- scLHloc[loc]+1
            end <- scLHloc[loc+1]-1
            if (is.na(end)) end <- length(Text)
            description <- Text[bg:end]
            description <- paste(description, "\n")
            if (!used) description <- c("Slot not used.")
            if (used && ! sl%in% c("EffYears", "EffLower", "EffUpper")) description <- c(valtext, description)

          } else {
            if (used & sl != "Source" & sl != "Name") description <- paste(valtext, "No justification provided.")
            if (!used) description <- "Slot not used. "
          }

          description[description == " \n"] <- "\n\n"
          # description[length(description)-1] <- "  "
          
          if (inc.descript) {
            des <- switch(class, 
                          "Stock" = DLMtool::StockDescription,
                          "Fleet" = DLMtool::FleetDescription,
                          "Obs" = DLMtool::ObsDescription,
                          "Imp" = DLMtool::ImpDescription)
            
            rownames(des) <- des[,1]
          
            cat("**", sl, "**: ", des[sl, 2], append=TRUE, file=RMDfile, sep="")
            cat("\n\n", description,"\n\n", append=TRUE, file=RMDfile, sep="")
            
          } else {
            cat("**", sl, "**:\n",  description,"\n\n", append=TRUE, file=RMDfile, sep="")
          }
          
          if (used && sl == "EffUpper") {
            cat("<style type='text/css'>\n", append=TRUE, file=RMDfile, sep="")
            cat(".table {\n", append=TRUE, file=RMDfile, sep="")
            cat("    width: 75%; \n", append=TRUE, file=RMDfile, sep="")
            cat("}\n", append=TRUE, file=RMDfile, sep="")
            cat("</style>\n", append=TRUE, file=RMDfile, sep="")
            
            cat("```{r, echo=FALSE, results='asis'}\n", append=TRUE, file=RMDfile, sep="")
            cat("knitr::kable(round(Effvals,2), format='markdown', caption='')\n", append=TRUE, file=RMDfile, sep="")
            cat("```\n\n", append=TRUE, file=RMDfile, sep="")
            
          }
          
          
          # Plots ####
          if (inc.plot) {
            if (class %in% c("Stock", "Fleet")) {
              if (sl == slots[length(slots)]) plotText(OM, slots, RMDfile)
            } 
        
          }
        }
      }
    }
    
    if ((class == "Obs" | class =='Imp') & inc.plot) {
      plotText(OM, slots=class, RMDfile)
    }
  }
}



writeCSV2 <- function(inobj, tmpfile = NULL, objtype = c("Stock", "Fleet", 
                                                         "Obs", "Imp", "Data", "OM", "Fease")) {
  objtype <- match.arg(objtype)
  
  for (X in 1:nrow(inobj)) {
    indat <- inobj[X, ]
    index <- which(!is.na(indat))
    if (length(index) >1) {
      index <- 2:max(index)
      if (X == 1) 
        write(do.call(paste, c(indat[1], as.list(indat[index]), sep = ",")), tmpfile, 1)
      if (X > 1) 
        write(do.call(paste, c(indat[1], as.list(indat[index]), sep = ",")), tmpfile, 1, append = TRUE)    
    } else if (indat[1] != "Slot") {
      write(unlist(indat[1]), tmpfile, 1, append = TRUE)  
    }
    
  }
}

