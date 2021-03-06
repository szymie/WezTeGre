package pl.weztegre.controllers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.codec.Base64;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import pl.weztegre.enums.State;
import pl.weztegre.formObjects.AdvertisementForm;
import pl.weztegre.formObjects.MessageForm;
import pl.weztegre.jsons.AdvertisementFilterJSON;
import pl.weztegre.jsons.AdvertisementJSON;
import pl.weztegre.jsons.MessageJSON;
import pl.weztegre.models.*;
import pl.weztegre.services.*;

import javax.servlet.http.HttpServletResponse;
import javax.validation.Valid;
import java.io.IOException;
import java.security.Principal;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

@Controller
@RequestMapping(value = "/message")
public class MessageController {
    private static final Logger LOGGER = LoggerFactory.getLogger(MessageController.class);

    @Autowired
    private UserService userService;

    @Autowired
    private MessageService messageService;

    @RequestMapping(value = "/add", method = RequestMethod.GET)
    public String addPage(Model model) {
        model.addAttribute("users", userService.findAll());

        return "addMessage";
    }

    @RequestMapping(value = "/{id}", method = RequestMethod.GET)
    public String showPage(@PathVariable("id") Integer id, Model model) {
        model.addAttribute("message", messageService.findOne(id));

        return "message";
    }

    @RequestMapping(value = "/add", method = RequestMethod.POST,
            consumes = "application/json", produces = "application/json")
    @ResponseBody
    public MessageJSON addMessage(@Valid @RequestBody MessageForm messageForm, BindingResult result, Principal userPrincipal) {
        MessageJSON messageJSON = new MessageJSON();
        if(!result.hasErrors()) {
            Date time = Calendar.getInstance().getTime();

            User sender = userService.findByEmail(userPrincipal.getName());
            User addressee = userService.findOne(messageForm.getAddressee().getId());

            Message message = new Message(
                    sender,
                    addressee,
                    messageForm.getSubject(),
                    messageForm.getContent(),
                    time,
                    time
            );

            try {
                message = messageService.save(message);
            } catch (Exception e) {
                e.printStackTrace();
            }

            messageJSON.setRedirect("message/" + message.getId());
        } else {
            for(Object item : result.getAllErrors()) {
                if(item instanceof FieldError) {
                    FieldError fieldError = (FieldError) item;

                    if(fieldError.getField().contains("subject"))
                        messageJSON.setSubjectError(fieldError.getDefaultMessage());
                    else if(fieldError.getField().contains("content"))
                        messageJSON.setContentError(fieldError.getDefaultMessage());
                }
            }
        }

        return messageJSON;
    }

    @RequestMapping(value = "/list", method = RequestMethod.GET)
    public String listMessages(Model model, Principal userPrincipal) {
        model.addAttribute("messages",
                messageService.findByIdOrderByDateDescTimeDesc(userService.findByEmail(userPrincipal.getName())));

        return "listOfMessages";
    }
}
