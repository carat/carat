<?xml version="1.0" encoding="UTF-8" ?>

<!--
	combine
	Created by .. .. on 2010-10-20.
	Copyright (c) 2010 . All rights reserved.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exslt="http://exslt.org/common" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>


	<xsl:template match="/">

		<html>
			<head>

				<link rel="stylesheet" type="text/css" href="template.css"/>

				<title>Carat - Analysis Report Example</title>
			</head>
			<body>
				<table>
					<tr>
						<td width="10%"/>
						<td width="80%">
							<img src="images/carat-banner.png"/>
							<br/>
							<br/>
							<br/>

							<!-- Start of summary block -->
							<h1>Summary</h1>
							<p> Instituto association publicationes non ha, se sia peano lateres.
								Lingua programma con e, uno se asia lateres, web lista vocabulos
								americano un! Al uso iala articulos. In sitos publicate del! Que il
								historia ascoltar, il con gode secundo denomination, uno de europeo
								historia instruite. Un lingua studio subjecto pro. Americas
								preparation pan es, un nos vista resultato anglo-romanic. O duce
								nomina grammatica pan? Post sitos via un, parola programma
								methodicamente uso tu, in nos contos historiettas. Uso ma deler
								libera, toto deler con o, il esseva litteratura nos?<br/><br/>
							</p>
							<br/>


							<!-- Start Environment -->
							<h2>Outbound HTTP Tests</h2>
							<p>The test client was trying to reach different websites using the Internet Explorer.
								The list below displays what URL's where part of this test and the result. <br/>
								If requests could not be recorded it is a strong indicator that there is a mechanism
								active on the client, which prevent the browser to reach the destination website
								emulated by the testing server.
								<br/><br/>
							</p>
							
							<br/>

							<table class="outertable" width="100%" rules="all">
								<tr bgcolor="#e9ab83">
									<th align="left">Status</th>
									<th align="left">Time</th>
									<th align="left">URL</th>
								</tr>
								<xsl:for-each
									select="document('outbound_results.xml')/document/request">
								        <tr>
										<td>
											<xsl:value-of select="status"/>
										</td>
										<td>
											<xsl:value-of select="timestamp"/>
										</td>
										<td>
											<xsl:value-of select="url"/>											
										</td>
								</tr>
								</xsl:for-each>
							</table>
							</td><td wdith="10%"></td></tr></table>
			</body>
		</html>

	</xsl:template>
</xsl:stylesheet>
