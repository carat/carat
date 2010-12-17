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
							<!-- End of summary block -->

							<!-- Start scaninfo -->
							<h2>Target information</h2>
							<p>This section holds some basic information about the scanned target
								and the scan settings used.</p>

							<table class="outertable" width="100%" rules="all">
								<tr bgcolor="#e9ab83">
									<th align="left" width="20%">Name</th>
									<th align="left" width="80%">Value</th>
								</tr>
								<tr>
									<td>Caption</td>
									<td>
										<xsl:value-of
											select="document('COMPUTERSYSTEM.xml')/COMMAND/RESULTS/CIM/INSTANCE/PROPERTY[@NAME='Caption']/VALUE"
										/>
									</td>
								</tr>
								<tr>
									<td>Domain</td>
									<td>
										<xsl:value-of
											select="document('COMPUTERSYSTEM.xml')/COMMAND/RESULTS/CIM/INSTANCE/PROPERTY[@NAME='Domain']/VALUE"
										/>
									</td>
								</tr>
								<tr>
									<td>Username</td>
									<td>
										<xsl:value-of
											select="document('COMPUTERSYSTEM.xml')/COMMAND/RESULTS/CIM/INSTANCE/PROPERTY[@NAME='UserName']/VALUE"
										/>
									</td>
								</tr>
								<tr>

									<td>NIC Configuration</td>
									<td>
										<xsl:for-each
											select="document('NICCONFIG.xml')/COMMAND/RESULTS/CIM/INSTANCE">
											<table class="innertable">
												<tr>
												<th width="30%">Interface Number <xsl:number
												value="position()" format="1 "/></th>
												<th/>
												</tr>
												<tr>
												<td>Name</td>
												<td width="70%">
												<xsl:value-of
												select="PROPERTY[@NAME='ServiceName']/VALUE"/>
												</td>
												</tr>
												<tr>
												<td>Description</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='Description']/VALUE"/>
												</td>
												</tr>
												<tr>
												<td>SettingID</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='SettingID']/VALUE"/>
												</td>
												</tr>
												<tr>
												<td>MAC Address</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='MACAddress']/VALUE"/>
												</td>
												</tr>
												<tr>
												<td>IPEnabled</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='IPEnabled']/VALUE"/>
												</td>
												</tr>

												<xsl:variable name="ipstate"
												select="PROPERTY[@NAME='IPEnabled']/VALUE"/>
												<xsl:if test="$ipstate='TRUE'">
												<tr>
												<td>DHCP Enabled</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='DHCPEnabled']/VALUE"/>
												</td>
												</tr>
												<tr>
												<td>IP Address</td>
												<td>
												<xsl:value-of
												select="PROPERTY.ARRAY[@NAME='IPAddress']/VALUE.ARRAY/VALUE"
												/>
												</td>
												</tr>
												<tr>
												<td>IP Subnet</td>
												<td>
												<xsl:value-of
												select="PROPERTY.ARRAY[@NAME='IPSubnet']/VALUE.ARRAY/VALUE"
												/>
												</td>
												</tr>
												<tr>
												<td>IPFilterSecurityEnabled</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='IPFilterSecurityEnabled']/VALUE"
												/>
												</td>
												</tr>
												<tr>
												<td>IPSecPermitIPProtocols</td>
												<td>
												<xsl:value-of
												select="PROPERTY.ARRAY[@NAME='IPSecPermitIPProtocols']/VALUE.ARRAY/VALUE"
												/>
												</td>
												</tr>
												<tr>
												<td>IPSecPermitTCPPorts</td>
												<td>
												<xsl:value-of
												select="PROPERTY.ARRAY[@NAME='IPSecPermitTCPPorts']/VALUE.ARRAY/VALUE"
												/>
												</td>
												</tr>
												<tr>
												<td>IPSecPermitUDPPorts</td>
												<td>
												<xsl:value-of
												select="PROPERTY.ARRAY[@NAME='IPSecPermitUDPPorts']/VALUE.ARRAY/VALUE"
												/>
												</td>
												</tr>
												<tr>
												<td>IP SecPermitIPProtocols</td>
												<td>
												<xsl:value-of
												select="PROPERTY.ARRAY[@NAME='IPSecPermitIPProtocols']/VALUE.ARRAY/VALUE"
												/>
												</td>
												</tr>
												<tr>
												<td>IP SecPermitIPProtocols</td>
												<td>
												<xsl:value-of
												select="PROPERTY.ARRAY[@NAME='IPSecPermitIPProtocols']/VALUE.ARRAY/VALUE"
												/>
												</td>
												</tr>
												<tr>
												<td>IP SecPermitIPProtocols</td>
												<td>
												<xsl:value-of
												select="PROPERTY.ARRAY[@NAME='IPSecPermitIPProtocols']/VALUE.ARRAY/VALUE"
												/>
												</td>
												</tr>
												</xsl:if>

												<tr>
												<td>IPXEnabled</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='IPXEnabled']/VALUE"/>
												</td>
												</tr>
												<xsl:variable name="ipxstate"
												select="PROPERTY[@NAME='IPXEnabled']/VALUE"/>
												<xsl:if test="$ipxstate='TRUE'">
												<tr>
												<td>IPXAddress</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='IPXAddress']/VALUE"/>
												</td>
												</tr>
												</xsl:if>
												<tr>
												<td>
												<br/>
												</td>
												<td> </td>
												</tr>
											</table>
										</xsl:for-each>


									</td>
								</tr>
							</table>
							<br/>
							<br/>

							<!-- End of scaninfo block -->

							<!-- Start Environment -->
							<h2>Environment Settings</h2>
							<table rules="all" width="100%" class="outertable">
								<tr bgcolor="#e9ab83">
									<th align="left" width="20%">Variable</th>
									<th align="left" width="20%">Usercontext</th>
									<th align="left" width="60%">Value</th>
								</tr>

								<xsl:for-each
									select="document('ENVIRONMENT.xml')/COMMAND/RESULTS/CIM/INSTANCE">
									<tr>
										<td>
											<xsl:value-of select="PROPERTY[@NAME='Name']/VALUE"/>
										</td>
										<td>
											<xsl:value-of select="PROPERTY[@NAME='UserName']/VALUE"
											/>
										</td>
										<td>
											<xsl:value-of
												select="PROPERTY[@NAME='VariableValue']/VALUE"/>
										</td>
									</tr>
								</xsl:for-each>
							</table>
							<!-- End of scaninfo block -->

							<!-- Start Useraccounts -->
							<h2>User accounts</h2>
							<p> This section of the document lists all discovered user
								accounts.<br/><br/>
							</p>

							<table border="0" cellpadding="5">
								<tr>
									<td> Starttime</td>
									<td>
										<xsl:value-of
											select="document('USERACCOUNT.xml')/COMMAND/@STARTTIME"
										/>
									</td>
								</tr>
								<tr>
									<td> Command</td>
									<td>wmic <xsl:value-of
											select="document('USERACCOUNT.xml')/COMMAND/REQUEST/COMMANDLINE"
										/>
									</td>
								</tr>
							</table>
							<br/>

							<table class="outertable" width="100%" rules="all">
								<tr bgcolor="#e9ab83">
									<th width="20%" align="left">Account</th>
									<th width="80%" align="left">Properties</th>
								</tr>
								<xsl:for-each
									select="document('USERACCOUNT.xml')/COMMAND/RESULTS/CIM/INSTANCE">
									<tr>
										<td>
											<xsl:value-of select="PROPERTY[@NAME='Name']/VALUE"/>
										</td>

										<td>
											<table class="innertable">
												<tr>
												<td width="30%">Fullname</td>
												<td width="70%">
												<xsl:value-of
												select="PROPERTY[@NAME='FullName']/VALUE"/>
												</td>
												</tr>
												<tr>
												<td>Domain</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='Domain']/VALUE"/>
												</td>
												</tr>
												<tr>
												<td>Description</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='Description']/VALUE"/>
												</td>
												</tr>
												<tr>
												<td>SID</td>
												<td>
												<xsl:value-of select="PROPERTY[@NAME='SID']/VALUE"
												/>
												</td>
												</tr>
												<tr>
												<td>Status</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='Status']/VALUE"/>
												</td>
												</tr>
												<tr>
												<td>Disabled</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='Disabled']/VALUE"/>
												</td>
												</tr>
												<tr>
												<td>Lockout</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='Lockout']/VALUE"/>
												</td>
												</tr>
												<tr>
												<td>PasswordRequired</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='PasswordRequired']/VALUE"
												/>
												</td>
												</tr>
												<tr>
												<td>PasswordExpires</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='PasswordExpires']/VALUE"/>
												</td>
												</tr>
												<tr>
												<td>PasswordChangeable</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='PasswordChangeable']/VALUE"
												/>
												</td>
												</tr>
												<tr>
												<td>LocalAccount</td>
												<td>
												<xsl:value-of
												select="PROPERTY[@NAME='LocalAccount']/VALUE"/>
												</td>
												</tr>
											</table>
										</td>
									</tr>
								</xsl:for-each>
							</table>


							<br/>



							<br/>
							<br/>
							<h2>Shares</h2>
							<p class="desc">This section of the report lists all the available share
								of one system. The shares has been evaluated using WMIC.</p>

							<table border="0" cellpadding="5">
								<tr>
									<td> Starttime</td>
									<td>
										<xsl:value-of
											select="document('SHARE.xml')/COMMAND/@STARTTIME"/>
									</td>
								</tr>
								<tr>
									<td> Command</td>
									<td>wmic <xsl:value-of
											select="document('SHARE.xml')/COMMAND/REQUEST/COMMANDLINE"
										/>
									</td>
								</tr>
							</table>
							<br/>

							<table class="outertable" width="100%" rules="all">
								<tr bgcolor="#e9ab83">
									<th align="left">No</th>
									<th align="left">Name</th>
									<th align="left">Path</th>
									<th align="left">Type</th>
									<th align="left">Description</th>
								</tr>
								<xsl:for-each
									select="document('SHARE.xml')/COMMAND/RESULTS/CIM/INSTANCE">
									<tr>
										<td>
											<xsl:number value="position()" format="1 "/>
										</td>
										<td>
											<xsl:value-of select="PROPERTY[@NAME='Name']/VALUE"/>
										</td>
										<td>
											<xsl:value-of select="PROPERTY[@NAME='Path']/VALUE"/>
										</td>
										<td><xsl:value-of select="PROPERTY[@NAME='Type']/VALUE"/>
											*</td>
										<td>
											<xsl:value-of
												select="PROPERTY[@NAME='Description']/VALUE"/>
										</td>
									</tr>
								</xsl:for-each>
							</table>
							<p> * Further details related to the type are available at
								http://msdn.microsoft.com/en-us/library/aa394435(VS.85).aspx. </p>
							<br/>
							<br/>
							<h2>Netstat - Connections</h2>

							<table rules="none" cellpadding="5px"
								style="table-layout:fixed;width:100%;border:0px solid #e9ab83;word-wrap:break-word;">
								<tr>
									<td align="left" width="50%">
										<img src="images/netstat.png"/>
									</td>
									<td align="left" valign="top" width="80%">
										<p class="desc">This section describes all the connection
											available at the system. The information has been
											gathered using the command "netstat -na".</p>
										<p>The chart on the left side visualizes the states of the
											connections. Please note, UDP is connection less and
											therefore now state information are available. Therefore
											all UDP connections are listed in our category.</p>
									</td>
								</tr>
							</table>
							<br/>

							<table class="outertable" width="100%" rules="all">
								<tr bgcolor="#e9ab83">
									<th align="left" width="5%">No</th>
									<th align="left" width="5%">Proto</th>
									<th align="left" width="30%">Local</th>
									<th align="left" width="30%">Remote</th>
									<th align="left" width="30%">Status</th>

								</tr>
								<xsl:for-each select="document('NETSTAT_NA.xml')/netstat_na/data">
									<tr>
										<td>
											<xsl:number value="position()" format="1 "/>
										</td>
										<td>
											<xsl:value-of select="protocol"/>
										</td>
										<td>
											<xsl:value-of select="local"/>
										</td>
										<td>
											<xsl:value-of select="remote"/>
										</td>
										<td>
											<xsl:value-of select="status"/>
										</td>
									</tr>
								</xsl:for-each>
							</table>

						</td>
						<td width="10%"/>
					</tr>
				</table>
			</body>
		</html>

	</xsl:template>
</xsl:stylesheet>
