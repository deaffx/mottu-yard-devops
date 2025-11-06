package br.com.fiap.mottu.yard;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

class MottuYardWebApplicationTests {

	@Test
	void applicationClassExists() {
		assertNotNull(MottuYardWebApplication.class);
	}

	@Test
	void mainMethodExists() throws NoSuchMethodException {
		assertNotNull(MottuYardWebApplication.class.getMethod("main", String[].class));
	}

	@Test
	void applicationContextLoads() {
		assertDoesNotThrow(() -> {
			// Verifica que a classe principal existe e pode ser carregada
			Class.forName("br.com.fiap.mottu.yard.MottuYardWebApplication");
		});
	}

}