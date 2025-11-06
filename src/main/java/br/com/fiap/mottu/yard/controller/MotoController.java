package br.com.fiap.mottu.yard.controller;

import br.com.fiap.mottu.yard.exception.BusinessException;
import br.com.fiap.mottu.yard.model.Moto;
import br.com.fiap.mottu.yard.service.MotoService;
import br.com.fiap.mottu.yard.service.PatioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Optional;

@Controller
@RequestMapping("/motos")
@RequiredArgsConstructor
public class MotoController {

    private final MotoService motoService;
    private final PatioService patioService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("motos", motoService.findAll());
        return "motos/list";
    }

    @GetMapping("/create")
    public String create(Model model) {
        model.addAttribute("moto", new Moto());
        model.addAttribute("patios", patioService.findAll());
        return "motos/form";
    }

    @PostMapping("/create")
    public String create(@Valid @ModelAttribute Moto moto, 
                        BindingResult result, 
                        Model model,
                        RedirectAttributes redirectAttributes) {
        
        // Carregar o pátio completo se o ID foi fornecido
        if (moto.getPatioAtual() != null && moto.getPatioAtual().getId() != null) {
            patioService.findById(moto.getPatioAtual().getId()).ifPresent(moto::setPatioAtual);
        }
        
        if (result.hasErrors()) {
            model.addAttribute("patios", patioService.findAll());
            return "motos/form";
        }

        // Verificar se placa já existe
        if (motoService.findByPlaca(moto.getPlaca()).isPresent()) {
            result.rejectValue("placa", "error.moto", "Placa já existe");
            model.addAttribute("patios", patioService.findAll());
            return "motos/form";
        }

        // Validar capacidade do pátio
        if (moto.getPatioAtual() != null && !patioService.hasCapacidade(moto.getPatioAtual())) {
            Long ocupacaoAtual = patioService.getOcupacaoAtual(moto.getPatioAtual());
            result.rejectValue("patioAtual", "error.moto", 
                "Pátio atingiu a capacidade máxima! " +
                "Ocupação: " + ocupacaoAtual + "/" + moto.getPatioAtual().getCapacidadeMaxima());
            model.addAttribute("patios", patioService.findAll());
            return "motos/form";
        }

        motoService.save(moto);
        redirectAttributes.addFlashAttribute("success", "Moto cadastrada com sucesso!");
        
        return "redirect:/motos";
    }

    @GetMapping("/edit/{id}")
    public String edit(@PathVariable("id") Long id, Model model, RedirectAttributes redirectAttributes) {
        return motoService.findById(id)
                .map(moto -> {
                    model.addAttribute("moto", moto);
                    model.addAttribute("patios", patioService.findAll());
                    return "motos/form";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("error", "Moto não encontrada!");
                    return "redirect:/motos";
                });
    }

    @PostMapping("/edit/{id}")
    public String edit(@PathVariable("id") Long id,
                      @Valid @ModelAttribute Moto moto,
                      BindingResult result,
                      Model model,
                      RedirectAttributes redirectAttributes) {
        
        // Buscar a moto original para comparar o pátio
        Moto motoOriginal = motoService.findById(id).orElse(null);
        
        // Carregar o pátio completo se o ID foi fornecido
        if (moto.getPatioAtual() != null && moto.getPatioAtual().getId() != null) {
            patioService.findById(moto.getPatioAtual().getId()).ifPresent(moto::setPatioAtual);
        }
        
        if (result.hasErrors()) {
            model.addAttribute("patios", patioService.findAll());
            return "motos/form";
        }

        // Verificar se placa já existe em outra moto
        Optional<Moto> motoExistente = motoService.findByPlaca(moto.getPlaca());
        if (motoExistente.isPresent() && !motoExistente.get().getId().equals(id)) {
            result.rejectValue("placa", "error.moto", "Esta placa já está cadastrada em outra moto");
            model.addAttribute("patios", patioService.findAll());
            return "motos/form";
        }

        // Validar capacidade se pátio mudou
        if (moto.getPatioAtual() != null && motoOriginal != null) {
            Long patioNovoId = moto.getPatioAtual().getId();
            Long patioAntigoId = motoOriginal.getPatioAtual() != null ? motoOriginal.getPatioAtual().getId() : null;
            
            // Se mudou de pátio, validar capacidade
            if (!patioNovoId.equals(patioAntigoId) && !patioService.hasCapacidade(moto.getPatioAtual())) {
                Long ocupacao = patioService.getOcupacaoAtual(moto.getPatioAtual());
                result.rejectValue("patioAtual", "error.moto", 
                    "Pátio lotado! Ocupação: " + ocupacao + "/" + moto.getPatioAtual().getCapacidadeMaxima());
                model.addAttribute("patios", patioService.findAll());
                return "motos/form";
            }
        }

        moto.setId(id);
        motoService.save(moto);
        redirectAttributes.addFlashAttribute("success", "Moto atualizada com sucesso!");
        
        return "redirect:/motos";
    }

    @GetMapping("/details/{id}")
    public String details(@PathVariable("id") Long id, Model model, RedirectAttributes redirectAttributes) {
        return motoService.findById(id)
                .map(moto -> {
                    model.addAttribute("moto", moto);
                    return "motos/details";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("error", "Moto não encontrada!");
                    return "redirect:/motos";
                });
    }

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable("id") Long id, RedirectAttributes redirectAttributes) {
        try {
            motoService.deleteById(id);
            redirectAttributes.addFlashAttribute("success", "Moto excluída com sucesso!");
        } catch (BusinessException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Não foi possível excluir a moto. Tente novamente.");
        }
        
        return "redirect:/motos";
    }
}