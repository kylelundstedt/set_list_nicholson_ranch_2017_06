library(googlesheets)
library(httr)
library(rvest)
library(stringr)
library(tidyverse)
library(magrittr)
library(huxtable)

# connect to Google Sheets
(my_sheets <- gs_ls())
# connect to Loosely Covered Set Lists workbook
set_lists <- gs_title("LC Gigs Set Lists")

# connect to gig-specific tab in that workbook
gig_name <- "2017-06 Jack London"
set_list <- set_lists %>% gs_read(ws = gig_name) %>%
  mutate( Artist = str_replace_all(Artist, "/", "-") ) %>%
  mutate( Artist = str_replace_all(Artist, "’" , "") ) %>%
  mutate( Artist = str_replace_all(Artist, "'", "") ) %>%
  mutate( Artist = str_replace_all(Artist, "&", "n") ) %>%
  mutate( Artist = str_replace_all(Artist, "\\.", "") ) %>%
  mutate( Title = str_replace_all(Title, "/", "-") ) %>%
  mutate( Title = str_replace_all(Title, "’" , "") ) %>%
  mutate( Title = str_replace_all(Title, "'", "") ) %>%
  mutate( Title = str_replace_all(Title, "&", "n") ) %>%
  mutate( Title = str_replace_all(Title, "\\.", "") ) %>%
  mutate( Artist_Title =
           str_c("https://www.songlyrics.com/", Artist, "/", Title, "-lyrics/") ) %>% 
  mutate( Artist_Title = str_to_lower(Artist_Title) ) %>% 
  mutate( Artist_Title = str_replace_all(Artist_Title, "\\s+", "-") ) %>% 
  mutate( Title_dash = str_replace_all(Title, " ", "-"))

# create RMarkdown file for gig-specific Lead Sheets

cover <- set_list %>% select(Title, Singer, Group) %>%
  as_hux() %>%
  huxtable::add_colnames() %>%
  set_bold(1, 1:3, TRUE) %>% 
  set_bottom_border(1, 1:3, 1) %>% 
  set_number_format(0)
cover <- set_font_size(cover, 2) 
cover2 <- cover %>% to_latex
write(cover2, file = "cover2.tex")

 
# set_background_color( where( (cover$Group %% 2) == 0 ), grey(0.95) ) %>% 

bookfilename <- str_c('book_filename: "', 
                      gig_name, '"\n', 
                      'rmd_files: [\n')
write(bookfilename, file = "_bookdown.yml")

songs <- paste0('\t"lead_sheets/',
                 set_list$Title_dash,
                 '.md",')
write(songs, file = "_bookdown.yml", append = TRUE)
outputs <- paste0('\n]\n',
                 'output_dir: docs')
write(outputs, file = "_bookdown.yml", append = TRUE)


