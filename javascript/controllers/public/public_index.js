import { application } from './public_application';
import SearchController from './search_controller';
import SubscribeController from './subscription_controller';

application.register('search', SearchController);
application.register('subscription', SubscribeController);
