// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title CedulaVotacao
 * @dev Implementa o processo de votacao 
 */
contract CedulaVotacao {
   
    struct Eleitor {        
        bool votado;      // if true, a eleitor ja votou
        address endereco; // Endereço da Wallet  - Carteira, identificador unico do eleitor
        uint voto;        // 
    }

    struct OpcoesVoto {
        bytes32 nome;   
        uint votoCount; 
    }

    mapping(address => Eleitor) public Eleitores;

    OpcoesVoto[] public OpcoesVotos;

    /** 
     * @dev Cria uma nova CedulaVotacao to choose one of 'OpcoesVotoNomes'.
     * @param OpcoesVotoNomes OpcoesVotos
     */
    constructor(bytes32[] memory OpcoesVotoNomes) {
        for (uint i = 0; i < OpcoesVotoNomes.length; i++) {
            OpcoesVotos.push(OpcoesVoto({
                nome: OpcoesVotoNomes[i],
                votoCount: 0
            }));
        }
    }
    
    /**
     * @dev endereco da wallet do eleitor
     * @param to para qual endereco esta indo o voto (SIM ou NAO)
     */
    function endereco(address to) public {
        Eleitor storage sender = Eleitores[msg.sender];
        require(!sender.votado, "O eleitor ja votou.");
        require(to != msg.sender, "Evita um loop de votos");

        while (Eleitores[to].endereco != address(0)) {
            to = Eleitores[to].endereco;
            //Evita um loop de votos
            require(to != msg.sender, "Loop detectado");
        }
        sender.votado = true;
        sender.endereco = to;
        Eleitor storage endereco_ = Eleitores[to];
        if (endereco_.votado) {
            // Se o endereco ja votou entao atribui o voto diretamente
            OpcoesVotos[endereco_.voto].votoCount += 1;
        }
    }

    /**
     * @dev Verifica se ja votou e realiza o voto nas opcoes voto'.
     * @param opcoesVoto Opcoes voto e um array e portando atribui para o indice da opcao por parametro
     */
    function voto(uint opcoesVoto) public {
        Eleitor storage sender = Eleitores[msg.sender];        
        require(!sender.votado, "Voce ja votou e nao pode votar novamente.");
        sender.votado = true;
        sender.voto = opcoesVoto;

        // Se passar um indice invalido sera disparada uma exception outOfRange
        // e quando isso acontecer todas as alteracoes serao desfeitas
        OpcoesVotos[opcoesVoto].votoCount += 1;
    }

    /** 
     * @dev Calcula e retorna a opcao vencedora.
     * @return vencedorOpcoesVoto_ e um indice e retornara o indice vencedor
     */
    function vencedorOpcoesVoto() public view
            returns (uint vencedorOpcoesVoto_)
    {
        uint vencedorvotoCount = 0;
        for (uint p = 0; p < OpcoesVotos.length; p++) {
            if (OpcoesVotos[p].votoCount > vencedorvotoCount) {
                vencedorvotoCount = OpcoesVotos[p].votoCount;
                vencedorOpcoesVoto_ = p;
            }
        }
    }

    /** 
     * @dev Busca dentro do indice o nome do vencedor
     * @return vencedorNome_ eh o nome do vencedor (SIM / NAO) ou qualquer outra opcao que vc queira atribuir
     */
    function vencedoNome() public view
            returns (bytes32 vencedorNome_)
    {
        vencedorNome_ = OpcoesVotos[vencedorOpcoesVoto()].nome;
    }
}
