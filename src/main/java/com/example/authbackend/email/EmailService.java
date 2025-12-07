package com.example.authbackend.email;

import com.sendgrid.*;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
public class EmailService {

    @Value("${sendgrid.api-key:}")
    private String sendGridApiKey;

    @Value("${app.email.from:no-reply@example.com}")
    private String fromAddress;

    public void sendWelcomeEmail(String toEmail, String name) {
        if (sendGridApiKey == null || sendGridApiKey.isEmpty()) {
            System.out.println("SendGrid API key not configured, skipping email.");
            return;
        }

        Email from = new Email(fromAddress);
        Email to = new Email(toEmail);
        String subject = "Welcome to our app!";
        String text = "Hi " + name + ",\n\nWelcome to our application!";
        Content content = new Content("text/plain", text);

        Mail mail = new Mail(from, subject, to, content);

        SendGrid sg = new SendGrid(sendGridApiKey);

        Request request = new Request();
        try {
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            Response response = sg.api(request);
            System.out.println("SendGrid status: " + response.getStatusCode());
        } catch (IOException ex) {
            System.out.println("Failed to send email: " + ex.getMessage());
        }
    }
}
