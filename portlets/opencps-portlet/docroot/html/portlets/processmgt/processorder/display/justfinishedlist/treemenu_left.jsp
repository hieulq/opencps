<%
/**
 * OpenCPS is the open source Core Public Services software
 * Copyright (C) 2016-present OpenCPS community
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
%>

<%@page import="com.liferay.portal.kernel.dao.search.SearchEntry"%>
<%@page import="com.liferay.portal.kernel.json.JSONFactoryUtil"%>
<%@page import="com.liferay.portal.kernel.json.JSONObject"%>
<%@page import="com.liferay.portal.kernel.language.LanguageUtil"%>
<%@page import="com.liferay.portal.kernel.log.Log"%>
<%@page import="com.liferay.portal.kernel.log.LogFactoryUtil"%>
<%@page import="com.liferay.portal.kernel.portlet.LiferayWindowState"%>
<%@page import="com.liferay.portlet.PortletURLFactoryUtil"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.List"%>
<%@page import="javax.portlet.PortletRequest"%>
<%@page import="javax.portlet.PortletURL"%>
<%@page import="org.opencps.dossiermgt.bean.ProcessOrderBean"%>
<%@page import="org.opencps.processmgt.search.ProcessOrderSearch"%>
<%@page import="org.opencps.processmgt.search.ProcessOrderSearchTerms"%>
<%@page import="org.opencps.processmgt.service.ProcessOrderLocalServiceUtil"%>
<%@page import="org.opencps.processmgt.util.ProcessOrderUtils"%>
<%@page import="org.opencps.processmgt.util.ProcessUtils"%>
<%@page import="org.opencps.util.DateTimeUtil"%>
<%@page import="org.opencps.util.MessageKeys"%>
<%@page import="org.opencps.util.WebKeys"%>

<%@ include file="../../init.jsp"%>

<liferay-ui:success  key="<%=MessageKeys.DEFAULT_SUCCESS_KEY %>" message="<%=MessageKeys.DEFAULT_SUCCESS_KEY %>"/>

<%
	PortletURL iteratorURL = renderResponse.createRenderURL();
	iteratorURL.setParameter("mvcPath", templatePath + "processorderjustfinishedlist.jsp");
	iteratorURL.setParameter("tabs1", ProcessUtils.TOP_TABS_PROCESS_ORDER_FINISHED_PROCESSING);
	
	List<ProcessOrderBean> processOrders =  new ArrayList<ProcessOrderBean>();
	
	int totalCount = 0;
	
// 	RowChecker rowChecker = new RowChecker(liferayPortletResponse);
	
	List<String> headerNames = new ArrayList<String>();
	
	headerNames.add("col1");
	headerNames.add("col2");
	headerNames.add("col3");
	
	String headers = StringUtil.merge(headerNames, StringPool.COMMA);
	
	String tabs1 = ParamUtil.getString(request, "tabs1", ProcessUtils.TOP_TABS_PROCESS_ORDER_WAITING_PROCESS);

	List<ProcessOrderBean> processOrderServices = new ArrayList<ProcessOrderBean>();
	
	List<ProcessOrderBean> processOrderSteps = new ArrayList<ProcessOrderBean>();
	
	long serviceInfoId = ParamUtil.getLong(request, "serviceInfoId");
	
	long processStepId = ParamUtil.getLong(request, "processStepId");
	
	try {

		if (tabs1
				.equals(ProcessUtils.TOP_TABS_PROCESS_ORDER_WAITING_PROCESS)) {
			processOrderServices = (List<ProcessOrderBean>) ProcessOrderLocalServiceUtil
					.getProcessOrderServiceByUser(themeDisplay
							.getUserId());
			if (serviceInfoId > 0) {
				processOrderSteps = (List<ProcessOrderBean>) ProcessOrderLocalServiceUtil
						.getUserProcessStep(themeDisplay.getUserId(),
								serviceInfoId);
			}
		} else {
			processOrderServices = (List<ProcessOrderBean>) ProcessOrderLocalServiceUtil
					.getProcessOrderServiceJustFinishedByUser(themeDisplay
							.getUserId());
			if (serviceInfoId > 0) {
				processOrderSteps = (List<ProcessOrderBean>) ProcessOrderLocalServiceUtil
						.getUserProcessStepJustFinished(
								themeDisplay.getUserId(), serviceInfoId);
			}
		}

	} catch (Exception e) {
	}

	//remove duplicates process orders
	Map<String, ProcessOrderBean> cleanMap = new LinkedHashMap<String, ProcessOrderBean>();
	for (int i = 0; i < processOrderSteps.size(); i++) {
		cleanMap.put(processOrderSteps.get(i).getProcessStepId() + "",
				processOrderSteps.get(i));
	}
	processOrderSteps = new ArrayList<ProcessOrderBean>(
			cleanMap.values());

	JSONObject arrayParam = JSONFactoryUtil.createJSONObject();
	arrayParam.put("serviceInfoId",
			(serviceInfoId > 0) ? String.valueOf(serviceInfoId)
					: StringPool.BLANK);
	arrayParam.put("processStepId",
			(processStepId > 0) ? String.valueOf(processStepId)
					: StringPool.BLANK);
	arrayParam.put("tabs1", tabs1);

	String processStepIdJsonData = ProcessOrderUtils.generateTreeView(
			processOrderSteps,
			LanguageUtil.get(locale, "filter-process-step").replaceAll(
					"--", StringPool.BLANK), "radio");
%>

<aui:row>
	<aui:col width="25">
		
		<c:if test="<%=serviceInfoId > 0 %>">
			<div style="margin-bottom: 25px;" class="opencps-searchcontainer-wrapper default-box-shadow radius8">
			
				<div id="processStepIdTree" class="openCPSTree"></div>
			
			</div>
		</c:if>
		
		<div class="opencps-searchcontainer-wrapper default-box-shadow radius8">
			
			<div id="serviceInfoIdTree" class="openCPSTree"></div>
			
			<%
			
			String serviceInfoIdJsonData = ProcessOrderUtils.generateTreeView(
					processOrderServices, 
					LanguageUtil.get(locale, "service-info").replaceAll("--", StringPool.BLANK) , 
					"radio");
			%>
			
		</div>
		
		<liferay-portlet:actionURL  var="menuCounterUrl" name="menuCounterAction"/>
		<liferay-portlet:actionURL  var="menuCounterServiceInfoIdUrl" name="menuCounterServiceInfoIdAction"/>
		
		<aui:script use="liferay-util-window,liferay-portlet-url">
		
			var serviceInfoId = '<%=String.valueOf(serviceInfoId) %>';
			var processStepId = '<%=String.valueOf(processStepId) %>';
			var serviceInfoIdJsonData = '<%=serviceInfoIdJsonData%>';
			var processStepIdJsonData = '<%=processStepIdJsonData%>';
			var arrayParam = '<%=arrayParam.toString() %>';
			
			AUI().ready(function(A){
				buildTreeView(
					"serviceInfoIdTree", 
					"serviceInfoId", 
					serviceInfoIdJsonData, 
					arrayParam, 
					'<%= PortletURLFactoryUtil.create(request, WebKeys.PROCESS_ORDER_PORTLET, themeDisplay.getPlid(), PortletRequest.RENDER_PHASE) %>', 
					'<%=templatePath + "processorderjustfinishedlist.jsp" %>', 
					'<%=LiferayWindowState.NORMAL.toString() %>', 
					'normal',
					'<%=menuCounterServiceInfoIdUrl.toString() %>',
					serviceInfoId,
					'<%=renderResponse.getNamespace() %>',
					'<%=hiddenJustFinishedListEmptyNode%>'
				);
				
				buildTreeView("processStepIdTree", 
					'processStepId', 
					processStepIdJsonData, 
					arrayParam, 
					'<%= PortletURLFactoryUtil.create(request, WebKeys.PROCESS_ORDER_PORTLET, themeDisplay.getPlid(), PortletRequest.RENDER_PHASE) %>', 
					'<%=templatePath + "processorderjustfinishedlist.jsp" %>', 
					'<%=LiferayWindowState.NORMAL.toString() %>', 
					'normal',
					'<%=menuCounterUrl.toString() %>',
					processStepId,
					'<%=renderResponse.getNamespace() %>',
					'<%=hiddenJustFinishedListEmptyNode%>'
				);
				
			});
			
		</aui:script>
	
	</aui:col>
	
	<aui:col width="75" >
		<aui:form name="fm">
			<div class="opencps-searchcontainer-wrapper">
				<liferay-ui:search-container 
					searchContainer="<%= new ProcessOrderSearch(renderRequest, SearchContainer.DEFAULT_DELTA, iteratorURL) %>"
					headerNames="<%= headers %>"
				>
				
					<liferay-ui:search-container-results>
						<%
							ProcessOrderSearchTerms searchTerms = (ProcessOrderSearchTerms)searchContainer.getSearchTerms();
							
							serviceInfoId = searchTerms.getServiceInfoId();
						
							processStepId = searchTerms.getProcessStepId();
							
							try{
								
								%>
									<%@include file="/html/portlets/processmgt/processorder/processorder_justfinished_searchresults.jspf" %>
								<%
							}catch(Exception e){
								_log.error(e);
							}
						
							total = totalCount;
							results = processOrders;
							
							pageContext.setAttribute("results", results);
							pageContext.setAttribute("total", total);
						%>
					</liferay-ui:search-container-results>

					<liferay-ui:search-container-row 
						className="org.opencps.dossiermgt.bean.ProcessOrderBean" 
						modelVar="processOrder" 
						keyProperty="processOrderId"
						rowVar="row"
						stringKey="<%=true%>"
					>
						<%	
							String deadlineVal = Validator.isNotNull(processOrder.getDealine()) ? processOrder.getDealine() : StringPool.DASH;
							
							String cssStatusColor = "status-color-" + processOrder.getDossierStatus();
						%>
						
							<liferay-util:buffer var="boundcol1">
								<div class="row-fluid">
									<div class="row-fluid">
										<div class='<%= "text-align-right span1 " + cssStatusColor%>'>
											<i class='<%="fa fa-circle sx10 " + processOrder.getDossierStatus()%>'></i>
										</div>
										<div class="span2 bold-label">
											<liferay-ui:message key="reception-no"/>
										</div>
										<span class="span9">
											<%=processOrder.getReceptionNo() %>
										</span>
									</div>

									<div class="row-fluid">
										<div class='<%= "text-align-right span1 " + cssStatusColor%>'>
										</div>
										<div class="span2 bold-label">
											<liferay-ui:message key="service-name"/>
										</div>
										<span class="span9">
											<%=processOrder.getServiceName() %>
										</span>
									</div>
								</div>
							</liferay-util:buffer>
								
								<liferay-util:buffer var="boundcol2">
									<div class="row-fluid min-width340">
										<div class="span5 bold">
											<liferay-ui:message key="subject-name"/>	
										</div>
										<div class="span7">
											<%=processOrder.getSubjectName() %>
										</div>
									</div>
									
									<div class="row-fluid" >
										<div class="span5 bold">
											 <liferay-ui:message key="action-date"/>
										</div>
										
										<div class="span7">
											<%=Validator.isNotNull(processOrder.getActionDatetime())? 
													DateTimeUtil.convertDateToString(processOrder.getActionDatetime(), DateTimeUtil._VN_DATE_FORMAT)
													:StringPool.BLANK %>
										</div>
									</div>
									
									<div class="row-fluid min-width340">
										<div class="span5 bold">
											<liferay-ui:message key="step-name"/>
										</div>
										<div class='<%="span7 " + cssStatusColor %>'>
											<%=processOrder.getStepName() %>
										</div>
									</div>
									
									<div class="row-fluid min-width340">
										<div class="span5 bold">
											<liferay-ui:message key="y-kien"/>
										</div>
										
										<div class='<%="span7"%>'>
											<%= processOrder.getActionNote() %>
										</div>
									</div>
							</liferay-util:buffer>
						
							<%
								row.setClassName("opencps-searchcontainer-row");
								row.addText(boundcol1);
								row.addText(boundcol2);
								row.addJSP("center", SearchEntry.DEFAULT_VALIGN,  "/html/portlets/processmgt/processorder/justfinished_actions.jsp", config.getServletContext(), request, response);
								
							%>	
						</liferay-ui:search-container-row> 
					
					<liferay-ui:search-iterator type="opencs_page_iterator"/>
				</liferay-ui:search-container>
			</div>
		</aui:form>
	</aui:col>
</aui:row>

<%!
	private Log _log = LogFactoryUtil.getLog("html.portlets.dossiermgt.frontoffice.display.default.jsp");
%>
