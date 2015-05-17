package pl.weztegre.listeners;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ApplicationEventMulticaster;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.stereotype.Component;
import pl.weztegre.services.RoleService;

/**
* Klasa ContextRefreshedListener nasłuchuje na zdarzenie ContextRefreshedEvent
*/
@Component
public class ContextRefreshedListener implements ApplicationListener<ContextRefreshedEvent> {
    private final Logger LOGGER = LoggerFactory.getLogger(ContextRefreshedListener.class);

    private boolean configured = false;

    @Autowired
    private RoleService roleService;

	/**
	* Metoda onApplicationEvent sprawdza istnienie ról w systemie i odtwarza je, gdy potrzeba
	*/
    @Override
    public void onApplicationEvent(ContextRefreshedEvent contextRefreshedEvent) {
        if(roleService == null || configured == true)
            return;

        LOGGER.info("Wstepne konfigurowanie bazy danych. Dodawanie rol.");
        createRoleIfDoesntExist("ROLE_USER");
        createRoleIfDoesntExist("ROLE_ADMIN");

        configured = true;
    }

	/**
	* Metoda createRoleIfDoesntExist tworzy rolę
	* @param role Nazwa roli do utworzenia
	*/
    private void createRoleIfDoesntExist(String role) {
        if(roleService.findRole(role) == null) {
            LOGGER.info("Nie znaleziono roli " + role + ". Dodawanie...");
            roleService.createRole(role);
        }
        else
            LOGGER.info("Rola " + role + " juz istnieje.");
    }
}
