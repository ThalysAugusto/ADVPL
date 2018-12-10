#include "PROTHEUS.CH" 
#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"                                       `


USER FUNCTION AtendTel()    

Local aArea := GetArea()
Local  oGroup1 
Local  oButton1
Local  cArquivo := 'c:\ramal.txt' 
Local  cLinha := ''
Public oListbox
Public oListbox2
Public lLimpa := .T. 
Public nCont  := 29
Public nIni   := 1          
Public oGet1,oGet2,oGet3,oGet4,oGet5,oGet6
Public cCliente := "                                                     "
Public cEnd     := "                                                     " 
Public cCep     := "        "
Public cTel     := "          "   
Public cComple  := "                                   "  
Public cBairro   := "                                   "   
Public cMun      := "                                   "
Public cEst      := "                                   "
Public aCo   := {{"      ","  ","                    ",,,,,,,}} 
Public aPedidos:= {{"000678","15/03/18","P13","1","70","70","00"}} 
Public cRet := ""  
Public oObj := tSocketClient():New()
Public nPort := 3446
//Public cIp   := 'kemigasbina.ddns.net'
Public cIp   := 'kemigas.ddns.net' 
//Public cIp   := 'localhost'
Public lRet  := .F. 
Public cConexao := ""  
Public cramal := ""


//+---------------------------------------------------------------------+
//| Abertura do arquivo texto                                           |
//+---------------------------------------------------------------------+
cArqTxt := cArquivo
		
nHdl := fOpen(cArqTxt,0 )
IF nHdl == -1
	IF FERROR()== 516
		ALERT("Nao foi possivel identificar o ramal.")
	EndIF
EndIf     

//+---------------------------------------------------------------------+
//| Verifica se foi possÃ­vel abrir o arquivo                            |
//+---------------------------------------------------------------------+
If nHdl == -1
	MsgAlert("O arquivo de ramal "+cArquivo+" nao pode ser aberto!" )
	cramal := '6552'
     
Else
	FSEEK(nHdl,0,0 )
	nTamArq:=FSEEK(nHdl,0,2 )
	FSEEK(nHdl,0,0 )
	fClose(nHdl)
			
	FT_FUse(cArquivo )  //abre o arquivo
	FT_FGoTop()         //posiciona na primeira linha do arquivo
	FT_FGOTOP()
				
	cLinha := Alltrim(FT_FReadLn())
	
	FT_FUSE()
	fClose(nHdl) 
	alert(cLinha)
	cramal := cLinha
	
Endif

Static oDlg


DEFINE MSDIALOG oDlg TITLE "Buscar Clientes" FROM 000, 000  TO 600,750 COLORS 0, 16777215 PIXEL 

@ 010, 010 SAY oSay1 PROMPT "Nome:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL 
@ 020, 010 MSGET oGet1 VAR cCliente SIZE 200, 010 OF oGroup1 COLORS 0, 16777215 PIXEL 

@ 032, 010 SAY oSay1 PROMPT "Endereco:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL 
@ 042, 010 MSGET oGet2 VAR cEnd SIZE 200, 010 OF oGroup1 COLORS 0, 16777215 PIXEL  

@ 054, 010 SAY oSay1 PROMPT "CEP:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL 
@ 064, 010 MSGET oGet3 VAR cCep SIZE 060, 010 OF oGroup1 COLORS 0, 16777215 PIXEL

@ 054, 080 SAY oSay1 PROMPT "BAIRRO:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL 
@ 064, 080 MSGET oGet5 VAR cBairro SIZE 060, 010 OF oGroup1 COLORS 0, 16777215 PIXEL

@ 076, 010 SAY oSay1 PROMPT "TEL:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL 
@ 086, 010 MSGET oGet4 VAR cTel SIZE 060, 010 OF oGroup1 COLORS 0, 16777215 PIXEL 

@ 076, 080 SAY oSay1 PROMPT "COMPLE:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL 
@ 086, 080 MSGET oGet6 VAR cComple SIZE 060, 010 OF oGroup1 COLORS 0, 16777215 PIXEL

@ 020, 209 BUTTON oButton1 PROMPT "Buscar" SIZE 037, 012 ACTION (ADDCLI(),oListbox:Refresh()) OF oGroup1 PIXEL  
@ 020, 256 BUTTON oButton2 PROMPT "Limpar" SIZE 037, 012 ACTION (LIMPAR(),oListbox:Refresh()) OF oDlg PIXEL

@ 020, 310 BUTTON oButton2 PROMPT "Incluir/Alterar" SIZE 037, 012 ACTION (MATA030(),oListbox:Refresh()) OF oDlg PIXEL

//@ 080, 180 SAY oSay1 PROMPT "Saldo Etiquetas:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL 
//@ 075, 200 MSGET oGet3 VAR nCont    SIZE 016, 010 OF oDlg COLORS 0, 16777215 PIXEL   

//@ 080, 120 SAY oSay2 PROMPT "Iniciar em:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL 
//@ 075, 150 MSGET oGet4 VAR nIni VALID SALDO() PICTURE "@E 99"   SIZE 016, 010 OF oDlg COLORS 0, 16777215 PIXEL  



@ 110,015 LISTBOX oListbox FIELDS TITLE "CODIGO","LOJA","CLIENTE","END.                           ","COMPLEMENTO   ","BAIRRO      ","CEP      ","TEL.      ","CIDADE                      ","ESTADO"  SIZE 350,100 PIXEL
oListbox:SetArray(aCo)   
oListbox:bLine := {|| {aCo[oListbox:nAt,1],;  //codigo
                       aCo[oListbox:nAt,2],;  //LOJA
                       aCo[oListbox:nAt,3],;  //nome
                       aCo[oListbox:nAt,4],;  //endereço
                       aCo[oListbox:nAt,5],;  //complemento
                       aCo[oListbox:nAt,6],;  //bairro
                       aCo[oListbox:nAt,7],;  //cep    
                       aCo[oListbox:nAt,8],;  //tel
                       aCo[oListbox:nAt,9],;  //CIDADE
                       aCo[oListbox:nAt,10] }} //ESTADO


oListbox:bSeekChange := {|| pedidos(aCo[oListbox:nAt,1],aCo[oListbox:nAt,2]) } 
//oListbox:bLDblClick   := {|| alert('bLDblClick') } 


@ 220, 010 SAY oSay1 PROMPT "Ultimos pedidos:" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL 

@ 230,015 LISTBOX oListbox2 FIELDS TITLE "DATA","PEDIDO","PRODUTO","NOME","QUANTIDADE","VALOR","TOTAL" SIZE 350,50 PIXEL 

aPedidos:= {{"","","","","","",""}}

oListbox2:SetArray(aPedidos)   
oListbox2:bLine := {|| {aPedidos[oListbox2:nAt,1],;  //codigo
                       aPedidos[oListbox2:nAt,2],;  //nome
                       aPedidos[oListbox2:nAt,3],;  //endereço
                       aPedidos[oListbox2:nAt,4],;  //complemento
                       aPedidos[oListbox2:nAt,5],;  //bairro  //CIDADE  
                       aPedidos[oListbox2:nAt,6],;  //bairro  //CIDADE
                       aPedidos[oListbox2:nAt,7] }}   
                       
@ 090, 310 BUTTON oButton3 PROMPT "Novo Pedido " SIZE 050, 012 ACTION (u_PedTelg(aCo[oListbox:nAt,1],aCo[oListbox:nAt,2])) OF oDlg PIXEL
@ 090, 250 BUTTON oButton4 PROMPT "Consulta Cliente" SIZE 050, 012 ACTION (ConCli()) OF oDlg PIXEL 
@ 090, 190 BUTTON oButton4 PROMPT "Pedidos" SIZE 050, 012 ACTION (MATA410()) OF oDlg PIXEL

//DEFINE SBUTTON FROM 220,121 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())  

//conecta na bina 
if( !oObj:IsConnected() ) 
	nResp :=  oObj:Connect(nPort,cIp,1000)
	if nResp > 0 
		cConexao := "Conectado"
	Else
		cConexao := "Desconectado"
	endif
endif

nMilissegundos := 1000 // Disparo será de 2 em 2 segundos
 
oTimer := TTimer():New(nMilissegundos, {|| u_conBina() }, oDlg )
oTimer:Activate()

ACTIVATE DIALOG oDlg CENTERED

oObj:CloseConnection()

RETURN (.T.)

//função para adicionar cliente no listbox
STATIC FUNCTION ADDCLI() 

REMOVE()                                                         

cQuery := " "
cQuery += " SELECT A1_COD,A1_LOJA,A1_NOME,A1_END,A1_COMPLEM,A1_BAIRRO,A1_CEP,A1_MUN,A1_EST,A1_TEL FROM "+RETSQLNAME("SA1")
cQuery += " WHERE D_E_L_E_T_ = '' AND A1_NOME LIKE '%"+ALLTRIM(UPPER(cCliente))+"%' "
cQuery += " AND A1_END LIKE '%"+ALLTRIM(UPPER(cEnd))+"%' "
cQuery += " AND A1_COMPLEM LIKE '%"+ALLTRIM(UPPER(cComple))+"%' " 
cQuery += " AND A1_BAIRRO LIKE '%"+ALLTRIM(UPPER(cBairro))+"%' "
cQuery += " AND A1_CEP LIKE '%"+ALLTRIM(UPPER(cCep))+"%' "
cQuery += " AND A1_MUN LIKE '%"+ALLTRIM(UPPER(cMun))+"%' "
cQuery += " AND A1_TEL LIKE '%"+ALLTRIM(UPPER(cTel))+"%' "
//cQuery += " AND A1_FILIAL = '"+CFILANT+"' "

TCQuery cQuery Alias "TMP1" New	

dbSelectArea("TMP1")
dbgotop()
  
WHILE !EOF()
     AADD(aCo,{TMP1->A1_COD,;
     		TMP1->A1_LOJA,;
            TMP1->A1_NOME,;
            TMP1->A1_END,;
            TMP1->A1_COMPLEM,;
            TMP1->A1_BAIRRO,;
            TMP1->A1_CEP,; 
            TMP1->A1_TEL,;
            TMP1->A1_MUN,;
            TMP1->A1_EST})      
dbskip()
End

dbcloseArea()

RETURN  

//função para remover cliente no listbox
STATIC FUNCTION REMOVE() 

    
aCo   := {{"      ","  ","                    ",,,,,,,}} 

oListbox:SetArray(aCo)   
oListbox:bLine := {|| {aCo[oListbox:nAt,1],;  //codigo  
					   aCo[oListbox:nAt,2],;  //LOJA
                       aCo[oListbox:nAt,3],;  //nome
                       aCo[oListbox:nAt,4],;  //endereço
                       aCo[oListbox:nAt,5],;  //complemento
                       aCo[oListbox:nAt,6],;  //bairro
                       aCo[oListbox:nAt,7],;  //cep    
                       aCo[oListbox:nAt,8],;  //tel
                       aCo[oListbox:nAt,9],;  //CIDADE
                       aCo[oListbox:nAt,10] }} //ESTADO 


RETURN 

STATIC FUNCTION LIMPAR()
 
cCliente := "                                                     "
cEnd     := "                                                     " 
cCep     := "        "
cTel     := "          "   
cComple  := "                                   "  
cBairro   := "                                   "   
cMun      := "                                   "
cEst      := "                                   "

								                      
oGet1:Refresh() 
oGet2:Refresh()
oGet3:Refresh()
oGet4:Refresh()
oGet5:Refresh() 

aCo   := {{"      ","  ","                    ",,,,,,,}} 
aPedidos := aPedidos:= {{"","","","","","",""}} 

oListbox:SetArray(aCo)   
oListbox:bLine := {|| {aCo[oListbox:nAt,1],;  //codigo  
					   aCo[oListbox:nAt,2],;  //LOJA
                       aCo[oListbox:nAt,3],;  //nome
                       aCo[oListbox:nAt,4],;  //endereço
                       aCo[oListbox:nAt,5],;  //complemento
                       aCo[oListbox:nAt,6],;  //bairro
                       aCo[oListbox:nAt,7],;  //cep    
                       aCo[oListbox:nAt,8],;  //tel
                       aCo[oListbox:nAt,9],;  //CIDADE
                       aCo[oListbox:nAt,10] }} //ESTADO   

oListbox2:SetArray(aPedidos)   
oListbox2:bLine := {|| {aPedidos[oListbox2:nAt,1],;  
                       aPedidos[oListbox2:nAt,2],;  
                       aPedidos[oListbox2:nAt,3],;  
                       aPedidos[oListbox2:nAt,4],;  
                       aPedidos[oListbox2:nAt,5],;  
                       aPedidos[oListbox2:nAt,6],;  
                       aPedidos[oListbox2:nAt,7] }} 

oListbox:Refresh()  
oListbox2:Refresh()

Return


STATIC FUNCTION RETORNO()
	cRet := aCo[oListbox:nAt,1]
Return    

Static Function Pedidos(cCli,cLoja)

cQuery := " "
cQuery += " SELECT C6_ENTREG,C6_NUM,C6_PRODUTO,B1_DESC,C6_QTDVEN,C6_PRCVEN,C6_VALOR FROM "+RETSQLNAME("SC6")
cQuery += " INNER JOIN "+RETSQLNAME("SB1")+" ON (B1_COD = C6_PRODUTO ) "
cQuery += " WHERE "+RETSQLNAME("SC6")+".D_E_L_E_T_ = '' AND C6_CLI = '"+cCli+"' AND "
cQuery += RETSQLNAME("SB1")+".D_E_L_E_T_ = '' "
cQuery += " AND C6_LOJA = '"+cLoja+"' " 
//cQuery += " AND C6_FILIAL = '"+CFILANT+"' " 
cQuery += " ORDER BY C6_ENTREG DESC "

TCQuery cQuery Alias "TMP2" New	

//EECVIEW(cQuery)

dbSelectArea("TMP2")
dbgotop()

aPedidos := {}

While !Eof()
	AADD(aPedidos,{DTOC(STOD(TMP2->C6_ENTREG)),TMP2->C6_NUM,TMP2->C6_PRODUTO,TMP2->B1_DESC,TMP2->C6_QTDVEN,TMP2->C6_PRCVEN,TMP2->C6_VALOR})	
	dbskip()	
Enddo

oListbox2:SetArray(aPedidos)   
oListbox2:bLine := {|| {aPedidos[oListbox2:nAt,1],;  
                       aPedidos[oListbox2:nAt,2],;  
                       aPedidos[oListbox2:nAt,3],;  
                       aPedidos[oListbox2:nAt,4],;  
                       aPedidos[oListbox2:nAt,5],;  
                       aPedidos[oListbox2:nAt,6],;  
                       aPedidos[oListbox2:nAt,7] }}   
                       
oListbox2:Refresh()

dbcloseArea("TMP2")

dbSelectArea("SA1")
dbsetorder(1) 
dbgotop()
dbseek(XFILIAL("SA1")+cCli+cLoja)  


Return    

Static Function ConCli()
      
Local aParam := {}
Local lPergunte := .F.
Local Inclui := .F.
Local Altera := .F.
Public aRotina	:=	{{"Pesquisa", "AxPesqui" , 0 , 1},; //"Pesquisar"
						    {"Visualiza", "AxVisual" , 0 , 2},;  //"Visualizar"
							 {"Consulta", "FC010CON" , 0 , 2},;  //"Consultar"
							 {"Imprime", "FC010IMP" , 0 , 4}}   //"Impressao"


lPergunte := Pergunte("FIC010",FunName()=="FINC010")		


If lPergunte .Or. FunName()<>"FINC010"

	aadd(aParam,MV_PAR01)
	aadd(aParam,MV_PAR02)
	aadd(aParam,MV_PAR03)
	aadd(aParam,MV_PAR04)
	aadd(aParam,MV_PAR05)
	aadd(aParam,MV_PAR06)
	aadd(aParam,MV_PAR07)
	aadd(aParam,MV_PAR08)
	aadd(aParam,MV_PAR09)
	aadd(aParam,MV_PAR10)
	aadd(aParam,MV_PAR11)
	aadd(aParam,MV_PAR12)
	aadd(aParam,MV_PAR13)
	aadd(aParam,MV_PAR14)
	aadd(aParam,MV_PAR15)


	Fc010Cli(aParam)

Endif

Return 

User Function ConBina()

Local oSayTel
Local oSayNom
Public aDados := {}
Public aDados2 := {}
Public cBuffer := ""  
Public nConta := 0  
Public oFont:= TFont():New("Arial",15,20,.T.,.T.,,,,,.F.) 
Public aBina := {}  
Public aAux  := {}
Static oDlg      



if( !oObj:IsConnected() ) 
  	lRet := .F.	
else
	lRet := .T.
endif 

if lRet .AND. ( nResp >= 0 ) 
//alert("entrou no loop")
		if( !oObj:IsConnected() ) 
  			lRet := .F.
  			Return 
  		Endif
 
		cBuffer := "" 
		aDados := {} 
		aDados2 := {}
		aBina  := {}
		aAux   := {}
		
		nResp = oObj:Receive( @cBuffer, 1000 )  
		
		if nResp = 0
			CONOUT( "--> Não recebi dados" )
  			lRet := .F.
  			Return 
  		Endif
		/*
		if alltrim(cBuffer) = ""
				   CONOUT( "--> Não recebi dados" )
				   aDados := {} 
				   aBina  := {}
				   aAux   := {}
				   lRet := .F. 
				   oObj:CloseConnection()
				   Return  
		Endif
		*/
		if( nResp >= 0 )
			   CONOUT( "--> Dados Recebidos " + StrZero(nResp,5) )
			   CONOUT( "--> "+cBuffer+"" ) 
			   //aDados := StrTokArr(cBuffer,",")
			   aBina := StrTokArr(cBuffer,Chr(13)+Chr(10),.T.) 
			   
			   for nx :=1 to len(aBina) 
			        
			   		AADD(aAux,StrTokArr(aBina[nx],","))
			   
			   next 
			   
			   ADados := aAux[1] 
			   
			   for nx :=1 to len(aAux) 
			        
					CONOUT(aAux[nx][1]+aAux[nx][2]+aAux[nx][3] )
	   
			   next 
			  
			   for nx :=1 to len(aAux) 
			        
			        if aAux[nx][2] = cRamal
			   			ADados := aAux[nx]
			   		endif
			   
			   next  
			   
		endif        
		
		if len(aDados) = 4
			if aDados[2] = cRamal
			    //alert("abre janela") 
			    //Aviso( "Chamada", 'Telefone', {},3, "",, '', .F., 5000 )
			    
			    cQuery := " "
				cQuery += " SELECT TOP 1 A1_COD,A1_LOJA,A1_NOME,A1_END,A1_CEP,A1_BAIRRO,A1_TEL FROM "+RETSQLNAME("SA1")
				cQuery += " WHERE D_E_L_E_T_ = '' "
				cQuery += " AND (A1_TEL LIKE '%"+ALLTRIM(SUBSTR(ALLTRIM(aDados[3]),3,9))+"%' OR A1_XCEL LIKE '%"+ALLTRIM(SUBSTR(ALLTRIM(aDados[3]),3,9))+"%' )" 
				
				IF Select("TMP3") > 0
					DbSelectArea("TMP3")
					DbCloseArea()
				ENDIF
				
				TCQuery cQuery Alias "TMP3" New	
				
				dbSelectArea("TMP3")                                                                           
				dbgotop()			    
				
				if aDados[1] = "01"  
				   
				    if ALLTRIM(TMP3->A1_NOME) <> ""
					   
				        cCliente := TMP3->A1_NOME
						cEnd := TMP3->A1_END 
						cCep := TMP3->A1_CEP 
						cBairro := TMP3->A1_BAIRRO
						cTel:= TMP3->A1_TEL
						
						ADDCLI()   
						oGet1:Refresh() 
						oGet2:Refresh()
						oGet3:Refresh()
						oGet4:Refresh()
						oGet5:Refresh()
						
						oListbox:Refresh()
					endif
					
				else 
					if aDados[1] = "00" 
						DEFINE MSDIALOG oDlg TITLE "Chamada" FROM 000, 000  TO 200, 600 COLORS 0, 16777215 PIXEL
						@ 043, 058 SAY oSayTel PROMPT "Telefone:" FONT oFont COLOR CLR_BLACK SIZE 100, 050 OF oDlg COLORS 0, 16777215 PIXEL
						@ 044, 137 SAY oSayNom PROMPT aDados[3] FONT oFont COLOR CLR_BLACK SIZE 100, 050 OF oDlg COLORS 0, 16777215 PIXEL
						@ 064, 058 SAY oSayNom PROMPT (TMP3->A1_NOME) FONT oFont COLOR CLR_BLACK SIZE 200, 050 OF oDlg COLORS 0, 16777215 PIXEL 
						oTimer := TTimer():New(1000, {|| AnaAt()}, oDlg )   
				    	oTimer:Activate()   
						ACTIVATE MSDIALOG oDlg CENTERED	 
					ENDIF
					
				endif
				
				if aDados[1] = "02" 
							cCliente := "                                                     "
							cEnd     := "                                                     " 
							cCep     := "        "
							cTel     := "          "   
							cComple  := "                                   "  
							cBairro   := "                                   "   
							cMun      := "                                   "
							cEst      := "                                   "
								
							oGet1:Refresh() 
							oGet2:Refresh()
							oGet3:Refresh()
							oGet4:Refresh()
							oGet5:Refresh()
							
							LIMPAR()
								
				Endif
				
				
				
				dbCloseArea()
				//oDlg:oTimer:DeActivate()
			
			   //	alert("fecha janela janela")
			   //	nConta := 0
			
			Endif
		Else  
		   /*
			DEFINE MSDIALOG oDlg TITLE "Chamada" FROM 000, 000  TO 200, 600 COLORS 0, 16777215 PIXEL
				@ 043, 058 SAY oSay1 PROMPT "Aguardando chamada" FONT oFont COLOR CLR_BLACK SIZE 200, 050 OF oDlg COLORS 0, 16777215 PIXEL				
				oTimer := TTimer():New(5000, {|| oDlg:End()}, oDlg )   
			    oTimer:Activate()
				
			ACTIVATE MSDIALOG oDlg CENTERED
		   */
		   	//sleep(2000)
		    //nConta += 1   
		    
		    CONOUT( "--> Não recebi dados" )
		    aDados := {} 
		    aBina  := {}
		    aAux   := {}
			lRet := .F. 
		    //oObj:CloseConnection()
		    Return
		      
		Endif
Endif



Return




Static Function AnaAt()
		nResp = oObj:Receive( @cBuffer, 1000 )  
				
				if nResp = 0
					CONOUT( "--> Não recebi dados" )
		  			lRet := .F.
		  			Return 
		  		Endif
		
				if( nResp >= 0 )
					   CONOUT( "--> Dados Recebidos " + StrZero(nResp,5) )
					   CONOUT( "--> "+cBuffer+"" ) 
					   //aDados := StrTokArr(cBuffer,",")
					   aBina := StrTokArr(cBuffer,Chr(13)+Chr(10),.T.) 
					   
					   for nx :=1 to len(aBina) 
					        
					   		AADD(aAux,StrTokArr(aBina[nx],","))
					   
					   next 
					   
					   ADados := aAux[1] 
					   
					   for nx :=1 to len(aAux) 
					        
							CONOUT(aAux[nx][1]+aAux[nx][2]+aAux[nx][3] )
			   
					   next 
					  
					   for nx :=1 to len(aAux) 
					        
					        if aAux[nx][2] = cRamal
					   			ADados := aAux[nx]
					   		endif
					   
					   next
					   
					   for nx :=1 to len(aAux) 
					        
					        if aAux[nx][2] <> cRamal .AND. aAux[nx][1] = '01'
					   			ADados2 := aAux[nx]
					   		endif
					   
					   next  
					   
				endif        
				if len(aDados2) = 4
					if aDados2[1] = "01" .AND. aDados2[2] <> cRamal 
								oDlg:End()  
								
								cCliente := "                                                     "
								cEnd     := "                                                     " 
								cCep     := "        "
								cTel     := "          "   
								cComple  := "                                   "  
								cBairro   := "                                   "   
								cMun      := "                                   "
								cEst      := "                                   "
								
									
								ADDCLI()   
								oGet1:Refresh() 
								oGet2:Refresh()
								oGet3:Refresh()
								oGet4:Refresh()
								oGet5:Refresh()
									
					Endif
				endif
				
				
				if len(aDados) = 4
					if aDados[2] = cRamal
					    //alert("abre janela") 
					    //Aviso( "Chamada", 'Telefone', {},3, "",, '', .F., 5000 )
					    
					    cQuery := " "
						cQuery += " SELECT TOP 1 A1_COD,A1_LOJA,A1_NOME,A1_END,A1_CEP,A1_BAIRRO,A1_TEL FROM "+RETSQLNAME("SA1")
						cQuery += " WHERE D_E_L_E_T_ = '' "
						cQuery += " AND (A1_TEL LIKE '%"+ALLTRIM(SUBSTR(ALLTRIM(aDados[3]),3,9))+"%' OR A1_XCEL LIKE '%"+ALLTRIM(SUBSTR(ALLTRIM(aDados[3]),3,9))+"%' )" 
						
						IF Select("TMP3") > 0
							DbSelectArea("TMP3")
							DbCloseArea()
						ENDIF
						
						TCQuery cQuery Alias "TMP3" New	
						
						dbSelectArea("TMP3")                                                                           
						dbgotop()			    
						
						if aDados[1] = "01"
							oDlg:End()  
						   
						    if ALLTRIM(TMP3->A1_NOME) <> ""
							   
						        cCliente := TMP3->A1_NOME
								cEnd := TMP3->A1_END 
								cCep := TMP3->A1_CEP 
								cBairro := TMP3->A1_BAIRRO
								cTel:= TMP3->A1_TEL
								
								ADDCLI()   
								oGet1:Refresh() 
								oGet2:Refresh()
								oGet3:Refresh()
								oGet4:Refresh()
								oGet5:Refresh()
								
								oListbox:Refresh() 
								

								
							endif
							
						Endif 
						
						if aDados[1] = "02"
							oDlg:End()  
							
							cCliente := "                                                     "
							cEnd     := "                                                     " 
							cCep     := "        "
							cTel     := "          "   
							cComple  := "                                   "  
							cBairro   := "                                   "   
							cMun      := "                                   "
							cEst      := "                                   "
							
								
							ADDCLI()   
							oGet1:Refresh() 
							oGet2:Refresh()
							oGet3:Refresh()
							oGet4:Refresh()
							oGet5:Refresh()
								
						Endif
						
						
						dbCloseArea()
					
					Endif
				Else   				    
				    CONOUT( "--> Não recebi dados" )
				    aDados := {} 
				    aBina  := {}
				    aAux   := {}
					lRet := .F. 
				    //oObj:CloseConnection()
				    Return
				      
				Endif

Return

 

     