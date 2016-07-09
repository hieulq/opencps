/**
 * OpenCPS is the open source Core Public Services software
 * Copyright (C) 2016-present OpenCPS community

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>
 */

package org.opencps.jms.lookup;

import java.util.Properties;

import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.MessageConsumer;
import javax.jms.MessageProducer;
import javax.jms.Queue;
import javax.jms.QueueBrowser;
import javax.jms.Session;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import org.opencps.util.PortletConstants;
import org.opencps.util.PortletUtil;
import org.opencps.util.WebKeys;

import com.liferay.portal.kernel.exception.SystemException;

/**
 * @author trungnt
 */
public class JMSLookupFactory {

	/**
	 * @param companyId
	 * @param code
	 * @param remote
	 * @throws NamingException
	 * @throws SystemException
	 * @throws Exception
	 */
	public JMSLookupFactory(long companyId, String code, boolean remote)
		throws NamingException, SystemException, Exception {

		init(companyId, code, remote);
	}

	/**
	 * @param companyId
	 * @param code
	 * @param remote
	 * @throws SystemException
	 * @throws NamingException
	 * @throws JMSException
	 */
	protected void init(long companyId, String code, boolean remote)
		throws SystemException, NamingException, JMSException {

		Properties properties =
			PortletUtil.getJMSContextProperties(companyId, code, remote);

		Context context = new InitialContext(properties);

		ConnectionFactory connectionFactory =
			(ConnectionFactory) context.lookup(remote
				? PortletConstants.JMS_REMOTE_CONNECTION_FACTORY
				: PortletConstants.JMS_CONNECTION_FACTORY);

		Connection connection =
			connectionFactory.createConnection(
				properties.getProperty(Context.SECURITY_PRINCIPAL),
				properties.getProperty(Context.SECURITY_CREDENTIALS));

		Destination destination =
			(Destination) context.lookup(properties.getProperty(WebKeys.JMS_DESTINATION));

		Session session =
			connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

		this.setContext(context);
		this.setConnectionFactory(connectionFactory);
		this.setProperties(properties);
		this.setConnection(connection);
		this.setDestination(destination);
		this.setSession(session);

	}

	/**
	 * @throws Exception
	 */
	protected void createConsumer()
		throws Exception {

		MessageConsumer consumer = _session.createConsumer(_destination);

		setMessageConsumer(consumer);
	}

	/**
	 * @throws Exception
	 */
	protected void createProducer()
		throws Exception {

		MessageProducer producer = _session.createProducer(_destination);
		setMessageProducer(producer);

	}

	/**
	 * @throws Exception
	 */
	protected void createQueue()
		throws Exception {

		Queue queue =
			(Queue) _context.lookup(_properties.getProperty(WebKeys.JMS_DESTINATION));

		setQueue(queue);
	}

	/**
	 * @throws Exception
	 */
	protected void createQueueBrowser()
		throws Exception {

		createQueue();
		QueueBrowser queueBrowser = _session.createBrowser(_queue);

		setQueueBrowser(queueBrowser);
	}

	/**
	 * @throws JMSException
	 * @throws NamingException
	 */
	protected void destroy()
		throws JMSException, NamingException {

		stop();

		if (_connection != null) {
			_connection.close();;
		}

		if (_context != null) {
			_context.close();;
		}

		_destination = null;
		_connectionFactory = null;

		if (_messageConsumer != null) {
			_messageConsumer.close();
		}

		if (_messageProducer != null) {
			_messageProducer.close();
		}

		_properties = null;
		_queue = null;

		if (_queueBrowser != null) {
			_queueBrowser.close();
		}

		if (_session != null) {
			_session.close();
		}

	}

	/**
	 * @throws JMSException
	 */
	protected void start()
		throws JMSException {

		if (_connection != null) {
			_connection.start();
		}

	}

	/**
	 * @throws JMSException
	 */
	protected void stop()
		throws JMSException {

		if (_connection != null) {
			_connection.stop();
		}

	}

	public ConnectionFactory getConnectionFactory() {

		return _connectionFactory;
	}

	public Connection getConnection() {

		return _connection;
	}

	public Context getContext() {

		return _context;
	}

	public Destination getDestination() {

		return _destination;
	}

	public MessageConsumer getMessageConsumer() {

		return _messageConsumer;
	}

	public MessageProducer getMessageProducer() {

		return _messageProducer;
	}

	public Queue getQueue() {

		return _queue;
	}

	public QueueBrowser getQueueBrowser() {

		return _queueBrowser;
	}

	public Session getSession() {

		return _session;
	}

	public Properties getProperties() {

		return _properties;
	}

	public void setConnectionFactory(ConnectionFactory connectionFactory) {

		this._connectionFactory = connectionFactory;
	}

	public void setConnection(Connection connection) {

		this._connection = connection;
	}

	public void setContext(Context context) {

		this._context = context;
	}

	public void setDestination(Destination destination) {

		this._destination = destination;
	}

	public void setMessageConsumer(MessageConsumer messageConsumer) {

		this._messageConsumer = messageConsumer;
	}

	public void setMessageProducer(MessageProducer messageProducer) {

		this._messageProducer = messageProducer;
	}

	public void setQueue(Queue queue) {

		this._queue = queue;
	}

	public void setQueueBrowser(QueueBrowser queueBrowser) {

		this._queueBrowser = queueBrowser;
	}

	public void setSession(Session session) {

		this._session = session;
	}

	public void setProperties(Properties properties) {

		this._properties = properties;
	}

	private ConnectionFactory _connectionFactory;

	private Connection _connection;

	private Context _context;

	private Destination _destination;

	private MessageConsumer _messageConsumer;

	private MessageProducer _messageProducer;

	private Queue _queue;

	private QueueBrowser _queueBrowser;

	private Session _session;

	private Properties _properties;

}