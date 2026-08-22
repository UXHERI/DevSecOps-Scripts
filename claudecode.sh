#!/bin/bash

<< task
Installing Claude Code (native installer) on Ubuntu, adding it to PATH,
and configuring it to run on Amazon Bedrock (Opus 4.6) instead of the
direct Anthropic API.
task

# ANSI color codes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${YELLOW}${BOLD}Updating package lists...${RESET}"
sudo apt update -y && sudo apt upgrade -y

install_claude_code() {
    echo -e "${YELLOW}${BOLD}Installing Claude Code (native installer)...${RESET}"
    curl -fsSL https://claude.ai/install.sh | bash
    echo -e "${GREEN}${BOLD}✔ Claude Code installed successfully.${RESET}"
}

configure_path() {
    echo -e "${YELLOW}${BOLD}Ensuring ~/.local/bin is in PATH...${RESET}"
    if ! grep -q '$HOME/.local/bin' ~/.bashrc; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo -e "${GREEN}${BOLD}✔ Added ~/.local/bin to PATH in ~/.bashrc.${RESET}"
    else
        echo -e "${GREEN}${BOLD}✔ ~/.local/bin already present in PATH.${RESET}"
    fi
    export PATH="$HOME/.local/bin:$PATH"
}

verify_claude_installation() {
    echo -e "${YELLOW}${BOLD}Verifying Claude Code installation...${RESET}"
    if ! command -v claude >/dev/null 2>&1; then
        echo -e "${RED}${BOLD}❌ 'claude' command not found on PATH.${RESET}"
        return 1
    fi
    echo -e "${GREEN}${BOLD}✔ Claude Code is working correctly: $(claude --version)${RESET}"
}

configure_bedrock_env() {
    echo -e "${YELLOW}${BOLD}Configuring Amazon Bedrock environment variables...${RESET}"

    if ! grep -q "CLAUDE_CODE_USE_BEDROCK" ~/.bashrc; then
        cat >> ~/.bashrc << 'EOF'
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export ANTHROPIC_MODEL='us.anthropic.claude-opus-4-5-20251101-v1:0'
EOF
        echo -e "${GREEN}${BOLD}✔ Bedrock environment variables added to ~/.bashrc.${RESET}"
    else
        echo -e "${GREEN}${BOLD}✔ Bedrock environment variables already present in ~/.bashrc.${RESET}"
    fi

    export CLAUDE_CODE_USE_BEDROCK=1
    export AWS_REGION=us-east-1
    export ANTHROPIC_MODEL='us.anthropic.claude-opus-4-5-20251101-v1:0'
}

verify_aws_credentials() {
    echo -e "${YELLOW}${BOLD}Verifying AWS credentials...${RESET}"
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        echo -e "${RED}${BOLD}❌ AWS credentials not found or invalid. Run 'aws configure' or attach an IAM role.${RESET}"
        return 1
    fi
    echo -e "${GREEN}${BOLD}✔ AWS credentials verified: $(aws sts get-caller-identity --query 'Arn' --output text)${RESET}"
}

echo -e "${GREEN}${BOLD}********** CLAUDE CODE INSTALLATION STARTED **********${RESET}"

if ! install_claude_code; then
    echo -e "${RED}${BOLD}❌ CLAUDE CODE INSTALLATION FAILED!!!${RESET}"
    exit 1
fi

if ! configure_path; then
    echo -e "${RED}${BOLD}❌ CONFIGURING PATH FAILED!!!${RESET}"
    exit 1
fi

if ! verify_claude_installation; then
    echo -e "${RED}${BOLD}❌ CLAUDE CODE VERIFICATION FAILED!!!${RESET}"
    exit 1
fi

if ! configure_bedrock_env; then
    echo -e "${RED}${BOLD}❌ CONFIGURING BEDROCK ENVIRONMENT FAILED!!!${RESET}"
    exit 1
fi

if ! verify_aws_credentials; then
    echo -e "${YELLOW}${BOLD}⚠️ Skipping strict failure — configure AWS credentials before running 'claude'.${RESET}"
fi

echo -e "${GREEN}${BOLD}********** CLAUDE CODE INSTALLATION DONE **********${RESET}"

echo -e "${YELLOW}${BOLD}Reloading shell environment for '${USER}'...${RESET}"
source ~/.bashrc