import { Play, Pause, RotateCcw, Mic, MicOff, Phone, Globe } from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"

// Constants
// Server Status Constants
const ServerStatus = {
    RUNNING: 'RUNNING',
    STOPPED: 'STOPPED',
    RESTARTING: 'RESTARTING',
    STARTING: 'STARTING',
} as const;
type ServerStatusType = typeof ServerStatus[keyof typeof ServerStatus];

// Microphone Status Constants
const MicStatus = {
    INITIAL: 'INITIAL',
    PERMITTED: 'PERMITTED',
    LISTENING: 'LISTENING',
    MUTED: 'MUTED',
} as const;
type MicStatusType = typeof MicStatus[keyof typeof MicStatus];

// Model Types
interface ModelType {
    name: string;
    id: string;
    description?: {
        reasoning: 1 | 2 | 3 | 4 | 5;
        speed: 1 | 2 | 3 | 4 | 5;
    };
}


// API Calls


// Toolbar Component
const Toolbar = () => {
    const [isExpanded, setIsExpanded] = useState(true);
    const [serverStatus, setServerStatus] = useState<ServerStatusType>(ServerStatus.STARTING);
    const [micStatus, setMicStatus] = useState<MicStatusType>(MicStatus.INITIAL);
}