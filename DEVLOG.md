# Diário de desenvolvimento

## 28/10/2026 — Base correspondente à Aula 08
- Criada arena vista de cima, quatro canteiros e muros com colisão.
- Criado personagem que anda com WASD ou setas, com velocidade diagonal normalizada.
- Arte provisória composta por formas geométricas; mecânicas de sobrevivência ficam para depois.
- Registro inicial feito na data real; não representa uma entrega realizada em 07/10.

## 11/11/2026 — Horta ampliada e partida de sobrevivência

A arena passou a ter 16 canteiros e 16 entradas para a horda. A navegação considera o espaço que uma lesma precisa para contornar cada canteiro, e a cerca tem colisão física. O jardineiro ganhou uma enxada e cinco corações. O relógio começa em três minutos e a frequência das ondas aumenta durante a partida. Testamos uma derrota por contato, o reinício e uma vitória percorrendo a arena por 180 segundos.

Depois, o cenário foi organizado nas camadas Terreno, Canteiros, Cultivos, Cerca e Itens. A enxada passou a ser coletada no chão, o HUD foi removido e as animações foram simplificadas. Essas alterações ficaram salvas localmente até o registro em Git em 18/11.

## 18/11/2026 — Verificação e registro da versão atual

Conferimos que o GitHub ainda continha apenas o commit inicial de 28/10. As alterações acumuladas foram organizadas em um commit da versão jogável e outro da documentação, ambos com a data real de 18/11. Os registros acima descrevem o trabalho local e não comprovam entregas nessas datas.

A validação desta versão conferiu as cinco camadas, a ausência do HUD, o bloqueio do ataque antes da coleta, a coleta da enxada, o ataque equipado, a derrota e o reinício. Também verificou a condição de vitória ao terminar a contagem. A duração configurada continua em 180 segundos.
