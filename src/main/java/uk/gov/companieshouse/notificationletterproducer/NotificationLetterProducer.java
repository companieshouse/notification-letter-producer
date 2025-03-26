package uk.gov.companieshouse.notificationletterproducer;

import org.apache.log4j.Logger;

import javax.jms.*;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Date;
import java.util.Hashtable;
import java.util.Properties;

/**
 * A thin client application for triggering the bulk letter generation process.
 * It is expected that the application will be scheduled on a nightly basis.
 * A JMS message containing the dispatch date is issued to the NotificationLetterProducerQueue.
 *
 * @author dpatterson
 * @see uk.gov.ch.chips.server.letterproducer.NotificationLetterProducerMDB
 */
public class NotificationLetterProducer {

    public static final Logger LOG = Logger.getLogger(NotificationLetterProducer.class);
    public final static String JNDI_FACTORY = "weblogic.jndi.WLInitialContextFactory";
    public final static String JMS_FACTORY = "uk.gov.ch.chips.jms.queue.CHQueueConnectionFactory";
    public final static String QUEUE = "uk.gov.ch.chips.jms.NotificationLetterProducerQueue";

    public final static String PROVIDER_URL = "notificationLetterProducer.provider.url";
    public final static String SECURITY_PRINCIPAL = "notificationLetterProducer.security.principal";
    public final static String SECURITY_CREDENTIALS = "notificationLetterProducer.security.credentials";

    private QueueConnection qcon;
    private QueueSession qsession;
    private QueueSender qsender;
    private Context ctx;
    private String jndiURL;
    private String username;
    private String password;

    /**
     * The public entrypoint to the notification letter producer.
     */
    public synchronized void execute(String propertyFile) {
        loadProperties(propertyFile);
        init(jndiURL);

        try {
            ObjectMessage message = qsession.createObjectMessage(new Date());
            qsender.send(message);
        } catch (JMSException ex) {
            LOG.error("Error sending message to NotificationLetterProducer queue.", ex);
        } finally {
            tearDown();
        }
    }

    void init(String url) {
        try {
            ctx = getInitialContext(url);
            QueueConnectionFactory qconFactory = (QueueConnectionFactory) ctx.lookup(JMS_FACTORY);
            qcon = qconFactory.createQueueConnection();
            qsession = qcon.createQueueSession(false, Session.AUTO_ACKNOWLEDGE);
            Queue queue = (Queue) ctx.lookup(QUEUE);
            qsender = qsession.createSender(queue);
            qcon.start();
        } catch (NamingException e) {
            e.printStackTrace();
            LOG.fatal("Error initialising NotificationLetterProducer. ", e);
            throw new Error("Error initialising NotificationLetterProducer. ", e);
        } catch (JMSException e) {
            e.printStackTrace();
            LOG.fatal("Error initialising NotificationLetterProducer. ", e);
            throw new Error("Error initialising NotificationLetterProducer. ", e);
        }
    }

    InitialContext getInitialContext(String url) throws NamingException {
        Hashtable<String, String> env = new Hashtable<>();
        env.put(Context.INITIAL_CONTEXT_FACTORY, JNDI_FACTORY);
        env.put(Context.PROVIDER_URL, url);
        env.put(Context.SECURITY_PRINCIPAL, username);
        env.put(Context.SECURITY_CREDENTIALS, password);
        return new InitialContext(env);
    }

    void loadProperties(String propertyFile) {
        // Read properties file.

        Properties properties = new Properties();
        try {
            properties.load(Files.newInputStream(Paths.get(propertyFile)));
            jndiURL = properties.getProperty(PROVIDER_URL);
            username = properties.getProperty(SECURITY_PRINCIPAL);
            password = properties.getProperty(SECURITY_CREDENTIALS);
        } catch (IOException e) {
            e.printStackTrace();
            LOG.fatal("Error initialising NotificationLetterProducer properties. ", e);
            throw new Error("Error initialising NotificationLetterProducer properties. ", e);
        }

    }

    /**
     * method to clear up un-required resources
     */
    void tearDown() {
        if (ctx != null) {
            ctx = null;
        }
        if (qcon != null) {
            try {
                qcon.close();
            } catch (JMSException e) {
                e.printStackTrace();
            }
        }

    }


}
