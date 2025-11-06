package br.com.fiap.mottu.yard.repository;

import br.com.fiap.mottu.yard.model.Moto;
import br.com.fiap.mottu.yard.model.Patio;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MotoRepository extends JpaRepository<Moto, Long> {
    Optional<Moto> findByPlaca(String placa);
    List<Moto> findByPatioAtual(Patio patio);
    List<Moto> findByStatusMoto(Moto.StatusMoto status);
    List<Moto> findByMarcaContainingIgnoreCase(String marca);
    List<Moto> findByModeloContainingIgnoreCase(String modelo);
    Page<Moto> findByModeloContainingIgnoreCaseOrMarcaContainingIgnoreCaseOrPlacaContainingIgnoreCase(String modelo, String marca, String placa, Pageable pageable);
    @Query("SELECT COUNT(m) FROM Moto m WHERE m.patioAtual = :patio")
    Long countMotosInPatio(@Param("patio") Patio patio);
}