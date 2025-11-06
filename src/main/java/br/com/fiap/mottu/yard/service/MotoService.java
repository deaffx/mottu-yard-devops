package br.com.fiap.mottu.yard.service;

import br.com.fiap.mottu.yard.exception.BusinessException;
import br.com.fiap.mottu.yard.model.Moto;
import br.com.fiap.mottu.yard.model.Patio;
import br.com.fiap.mottu.yard.repository.MotoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MotoService {

    private final MotoRepository motoRepository;

    public Page<Moto> findAll(Pageable pageable) {
        return motoRepository.findAll(pageable);
    }

    public Page<Moto> search(String termo, Pageable pageable) {
        String filtro = termo == null ? "" : termo.trim();
        return motoRepository.findByModeloContainingIgnoreCaseOrMarcaContainingIgnoreCaseOrPlacaContainingIgnoreCase(
                filtro,
                filtro,
                filtro,
                pageable
        );
    }

    public List<Moto> findAll() {
        return motoRepository.findAll();
    }

    public Optional<Moto> findById(Long id) {
        return motoRepository.findById(id);
    }

    public Optional<Moto> findByPlaca(String placa) {
        return motoRepository.findByPlaca(placa);
    }

    public Moto save(Moto moto) {
        return motoRepository.save(moto);
    }

    public void deleteById(Long id) {
        try {
            motoRepository.deleteById(id);
        } catch (DataIntegrityViolationException e) {
            throw new BusinessException("Não é possível excluir esta moto pois está registrada em manutenção", e);
        }
    }

    public List<Moto> findByPatio(Patio patio) {
        return motoRepository.findByPatioAtual(patio);
    }

    public List<Moto> findByStatus(Moto.StatusMoto status) {
        return motoRepository.findByStatusMoto(status);
    }

    public List<Moto> findByMarca(String marca) {
        return motoRepository.findByMarcaContainingIgnoreCase(marca);
    }

    public List<Moto> findByModelo(String modelo) {
        return motoRepository.findByModeloContainingIgnoreCase(modelo);
    }

    public Long countTotalMotos() {
        return motoRepository.count();
    }

    public Long countMotosByStatus(Moto.StatusMoto status) {
        return (long) motoRepository.findByStatusMoto(status).size();
    }

    public List<Moto> findRecentMotos(int limit) {
        return motoRepository.findAll(
            org.springframework.data.domain.PageRequest.of(0, limit, 
                org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC, "createdAt"))
        ).getContent();
    }
}