library(RMySQL)

#AIDS = read.csv("AIDS.csv",header = TRUE,sep = ",")
#Counties = read.csv("Counties.csv",header = TRUE,sep = ",")

con = dbConnect(RMySQL::MySQL(),dbname="hw02",host="140.138.224.61",username="user",password="123")
dbSendQuery(con,"SET NAMES utf8")
res = dbSendQuery(con, "SELECT * FROM `aids` ORDER BY `AIDS診斷年份` ASC,`AIDS診斷月份` ASC,`診斷年齡分組` ASC,`縣市別`")
AIDS = fetch(res, n = -1,)
res = dbSendQuery(con, "SELECT * FROM `counties`")
Counties = fetch(res, n = -1,)

