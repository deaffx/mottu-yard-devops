package br.com.fiap.mottu.yard.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "motos")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Moto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Size(max = 50)
    @Column(nullable = false)
    private String modelo;

    @NotBlank
    @Pattern(regexp = "^[A-Z]{3}[0-9][A-Z][0-9]{2}$|^[A-Z]{3}[0-9]{4}$", message = "Formato de placa inválido")
    @Column(unique = true, nullable = false)
    private String placa;

    @NotBlank
    @Size(max = 30)
    @Column(nullable = false)
    private String marca;

    @NotNull
    @Positive
    @Column(name = "ano_fabricacao", nullable = false)
    private Integer anoFabricacao;

    @Size(max = 20)
    private String cor;

    @PositiveOrZero
    private Integer quilometragem = 0;

    @Enumerated(EnumType.STRING)
    @Column(name = "status_moto", nullable = false)
    private StatusMoto statusMoto = StatusMoto.PARA_REGULARIZAR;

    @NotNull(message = "O pátio atual é obrigatório")
    @ManyToOne
    @JoinColumn(name = "patio_atual_id", nullable = false)
    private Patio patioAtual;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public enum StatusMoto {
        PARA_REGULARIZAR("Para regularizar", "Documentação pendente ou exigências legais a regularizar"),
        PARA_MANUTENCAO("Para manutenção", "Apresenta problemas mecânicos e aguarda encaminhamento"),
        NA_OFICINA("Na oficina", "Atualmente em execução de manutenção"),
        PARA_ALUGAR("Para alugar", "Em perfeitas condições para ser alugada");

        private final String label;
        private final String descricao;

        StatusMoto(String label, String descricao) {
            this.label = label;
            this.descricao = descricao;
        }

        public String getLabel() {
            return label;
        }

        public String getDescricao() {
            return descricao;
        }
    }
}