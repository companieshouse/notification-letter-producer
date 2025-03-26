package uk.gov.companieshouse.notificationletterproducer;

public class NotificationLetterProducerRunner {

    /**
     * @param args [0] URL for JNDI context binding. Eg t3://localhost:7001
     */
    public static void main(String[] args) {
        if (args == null || args.length != 1) {
            System.out.println("usage: NotificationLetterProducerRunner <properties filename>");
            return;
        }
        String propertyFile = args[0];
        NotificationLetterProducer producer = new NotificationLetterProducer();
        producer.execute(propertyFile);
    }

}
