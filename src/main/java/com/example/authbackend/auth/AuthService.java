package com.example.authbackend.auth;

import com.example.authbackend.auth.dto.*;
import com.example.authbackend.email.EmailService;
import com.example.authbackend.security.JwtService;
import com.example.authbackend.user.User;
import com.example.authbackend.user.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailService emailService;

    // Optional: configure in application.properties
    // app.n8n.webhook-url=https://your-n8n-instance/webhook/new-user
    private final String n8nWebhookUrl;

    public AuthService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService,
                       EmailService emailService,
                       org.springframework.core.env.Environment env) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.emailService = emailService;
        this.n8nWebhookUrl = env.getProperty("app.n8n.webhook-url", "");
    }

    public AuthResponse signup(SignupRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already in use");
        }

        User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        userRepository.save(user);

        // Send welcome email
        emailService.sendWelcomeEmail(user.getEmail(), user.getName());

        // Trigger n8n if configured
        triggerN8n(user);

        String token = jwtService.generateToken(user);
        return new AuthResponse(token, user.getName(), user.getEmail());
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }

        String token = jwtService.generateToken(user);
        return new AuthResponse(token, user.getName(), user.getEmail());
    }

    private void triggerN8n(User user) {
        if (n8nWebhookUrl == null || n8nWebhookUrl.isEmpty()) {
            return;
        }
        try {
            RestTemplate rt = new RestTemplate();
            Map<String, String> body = new HashMap<>();
            body.put("name", user.getName());
            body.put("email", user.getEmail());
            rt.postForEntity(n8nWebhookUrl, body, String.class);
        } catch (Exception e) {
            System.out.println("Failed to trigger n8n: " + e.getMessage());
        }
    }
}
